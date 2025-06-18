#!/usr/bin/env bash

set -e

lockfile=$(mktemp)
trap 'rm -f ${lockfile}; exit' INT EXIT

# Ensure only one event is handled at a time.
debounce_event() {
  (
    flock -n 200 || { echo "too fast" >&2; return 1; }

    handle_event
  ) 200>"${lockfile}"
}

normalize_network_state() {
  local state=$1

  case $state in
    routable)
      echo connected
      ;;
    off)
      echo off
      ;;
    *)
      echo disconnected
      ;;
  esac
}

handle_event() {
  local main_icon="web.disconnected"
  local main_percentage=0
  local main_toggle="disabled"
  local main_sublabel="Disconnected"

  # Look for interface that will be used to route normal traffic.
  local main_iface
  main_iface=$(ip route get 9.9.9.9 \
    | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}'
  )

  local jsons=""
  local iface type state
  while read -r _ iface type state _ ; do
    state=$(normalize_network_state "${state}")

    local icon="${type}.${state}"
    local percentage=0
    local toggle="disabled"
    local sublabel="Disconnected"

    case $type in
      wlan)
        toggle="on"
        if [[ $state == "off" ]]; then
          toggle="off"
        else
          local show
          show=$(iwctl station "${iface}" show)
          sublabel=$(awk '/Connected network/ { print $3 }' <<<"${show}")

          local rssi
          rssi=$(awk '/AverageRSSI/ { print $2 }' <<<"${show}")
          (( percentage = 2 * (rssi + 100) ))
          if [ $percentage -gt 100 ]; then
            percentage=100
          elif [ $percentage -lt 0 ]; then
            percentage=0
          fi
        fi
        ;;
      ether)
        sublabel="Ethernet"
        ;;
      # TODO: wwan?
      *)
        continue
        ;;
    esac

    if [[ $toggle == "on" ]]; then
      # At least one toggleable device exists.
      main_toggle="on"
    elif [[ $toggle == "off" && $main_toggle != "on" ]]; then
      # No other toggleable devices are on.
      main_toggle="off"
    fi

    if [[ $iface == "${main_iface}" ]]; then
      main_icon=$icon
      main_percentage=$percentage
      main_sublabel=$sublabel
    fi

    local json
    json="{
      \"icon\":\"${icon}\",
      \"percentage\":${percentage},
      \"toggle\":\"${toggle}\",
      \"sublabel\":\"${sublabel}\"
    }"
    jsons+="${json},"
  done < <(networkctl list --no-legend)

  # Use jq to compact and validate. Strip trailing comma.
  jq -c <<<"{
    \"all\":[${jsons:0:-1}],
    \"icon\":\"${main_icon}\",
    \"percentage\":${main_percentage},
    \"toggle\":\"${main_toggle}\",
    \"sublabel\":\"${main_sublabel}\"
  }"
}

while read -r line; do
  if [[ "$line" == *"PropertiesChanged"* ]] || [[ "$line" == "poll" ]]; then

    # Events can arrive in rapid bursts. No need to handle every one. Use a
    # debouncing strategy to avoid doing more work than necessary.
    debounce_event &
  fi
done < <(

  # Watch for state changes.
  dbus-monitor \
    --system \
    "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',sender='org.freedesktop.network1',arg0='org.freedesktop.network1.Link'" \
    "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',sender='net.connman.iwd',arg0='net.connman.iwd.Station'" \
    2>/dev/null &

  # Poll periodically in order to update signal strength.
  while true; do
    echo "poll"
    sleep 60
  done &
)

wait
