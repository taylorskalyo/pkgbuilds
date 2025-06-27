#!/usr/bin/env bash

set -e

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

# Buffer events. When multiple inputs arrive in quick succession, output only
# the latest.
debounce_events() {
  local line

  while true; do
    read -r line
    if [[ "$line" == *"PropertiesChanged"* ]] || [[ "$line" == "poll" ]]; then
      expire=$(( $(date +%s) + 1 ))

      # Flush fifo
      while read -t 0.1 -r latest; do
        line=$latest
        [[ $(date +%s) -gt $expire ]] && break
      done

      # Output latest event
      echo "${line}"
    fi
  done
}

handle_event() {
  local main_icon="web.disconnected"
  local main_percentage=0
  local main_state="disconnected"
  local main_disabled=true
  local main_label="Disconnected"

  # Look for interface that will be used to route normal traffic.
  local main_iface
  main_iface=$(ip route get 9.9.9.9 \
    | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}'
  )

  local networks=""
  local iface type state
  while read -r _ iface type state _ ; do
    state=$(normalize_network_state "${state}")

    local icon="${type}.${state}"
    local percentage=0
    local disabled=true
    local label="Disconnected"
    local station=""
    local stations=""

    case $type in
      wlan)
        disabled=false
        if [[ $state != "off" ]]; then
          if rfkill list wlan | grep off; then
            state="off"
          fi
        fi
        if [[ $state != "off" ]]; then
          local show
          show=$(iwctl station "${iface}" show)
          station=$(awk '/Connected network/ { print $3 }' <<<"${show}")
          label=$station

          local rssi
          rssi=$(awk '/AverageRSSI/ { print $2 }' <<<"${show}")
          (( percentage = 2 * (rssi + 100) ))
          if [ $percentage -gt 100 ]; then
            percentage=100
          elif [ $percentage -lt 0 ]; then
            percentage=0
          fi

          stations=$(wlan_stations "${iface}")
        fi
        ;;
      ether)
        label="Ethernet"
        ;;
      # TODO: wwan?
      *)
        continue
        ;;
    esac

    if [[ $disabled == false ]]; then
      # At least one toggleable device exists.
      main_disabled=false
    fi

    if [[ $state == "connected" ]]; then
      # At least one device is connected.
      main_state="connected"
    elif [[ $state == "off" && $main_state != "connected" ]]; then
      # No other toggleable devices are on.
      main_state="off"
    fi

    if [[ $iface == "${main_iface}" ]]; then
      main_icon=$icon
      main_percentage=$percentage
      main_label=$label
    fi

    networks+=$(cat <<-JSON
{
  "icon":"${icon}",
  "percentage":${percentage},
  "state":"${state}",
  "disabled":${disabled},
  "iface":"${iface}",
  "type":"${type}",
  "station":"${station}",
  "stations":[${stations}]
},
JSON
)
  done < <(networkctl list --no-legend)

  # Strip trailing ","
  if [[ -n $networks ]]; then
    networks="${networks:0:-1}"
  fi

  # Use jq to compact and validate
  jq -c <<-JSON
{
  "all":[${networks}],
  "icon":"${main_icon}",
  "percentage":${main_percentage},
  "state":"${main_state}",
  "disabled":"${main_disabled}",
  "label":"${main_label}"
}
JSON
}

wlan_stations() {
  local iface=$1

  local known
  known=$(iwctl known-networks list \
    | tail -n +5 \
    | strip_ansi \
    | awk '{ print $1 }')

  local stations=""

  local line
  while read -r line; do
    local connected=false
    local saved=false
    local ssid security dbms
    unset ssid security dbms

    if [[ $line =~ ^[[:space:]\>]*(.*[^[:space:]])[[:space:]]{2,}([^[:space:]]+)[[:space:]]{2,}(-?[0-9]+)$ ]]; then
      ssid="${BASH_REMATCH[1]}"
      ssid="${ssid//\"/\\\"}" # escape double quotes for JSON
      security="${BASH_REMATCH[2]}"
      dbms="${BASH_REMATCH[3]}"
      if [[ $line =~ ^\> ]]; then
        connected=true
      fi

      if [[ -n $ssid ]] && grep "${ssid}" <<< "${known}" >/dev/null; then
        saved=true
      fi

      (( percentage = 2 * (dbms / 100 + 100) ))
      if [ $percentage -gt 100 ]; then
        percentage=100
      elif [ $percentage -lt 0 ]; then
        percentage=0
      fi

      stations+=$(cat <<-JSON
{
  "ssid":"${ssid}",
  "security":"${security}",
  "connected":${connected},
  "saved":${saved},
  "percentage":${percentage}
},
JSON
)
    fi
  done < <(iwctl station "${iface}" get-networks rssi-dbms \
    | tail -n +5 \
    | strip_ansi
  )

  # Strip trailing ","
  if [[ -n $stations ]]; then
    stations="${stations:0:-1}"
  fi

  echo "${stations}"
}

strip_ansi() {
  sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
}

while read -r line; do
  handle_event
done < <(
  {
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
  } | debounce_events
)

wait
