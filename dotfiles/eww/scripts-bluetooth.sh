#!/bin/bash

set -e

handle_event() {
  local devices=""

  local powered=false
  local discovering=false
  local state_icon="bluetooth.off"
  local line
  while read -r line; do
    if [[ "$line" =~ Powered:\ (.*) ]]; then
      if [[ ${BASH_REMATCH[1]} == "yes" ]]; then
        powered=true
        state_icon="bluetooth.on"
      fi
    elif [[ "$line" =~ Discovering:\ (.*) ]]; then
      if [[ ${BASH_REMATCH[1]} == "yes" ]]; then
        discovering=true
      fi
    fi
  done < <(bluetoothctl show)

  local mac
  while read -r mac; do
    unset name icon connected paired audio

    local name icon
    local connected=false
    local paired=false
    local audio=false

    while read -r line; do
      if [[ "$line" =~ Name:\ (.*) ]]; then
        name=${BASH_REMATCH[1]}
      elif [[ "$line" =~ Connected:\ (.*) ]]; then
        if [[ ${BASH_REMATCH[1]} == "yes" ]]; then
          connected=true
          if [[ $state_icon == "bluetooth.on" ]]; then
            state_icon="bluetooth.connected"
          fi
        fi
      elif [[ "$line" =~ Paired:\ (.*) ]]; then
        if [[ ${BASH_REMATCH[1]} == "yes" ]]; then
          paired=true
        fi
      elif [[ "$line" =~ Icon:\ (.*) ]]; then
        icon=${BASH_REMATCH[1]}
      elif [[ "$line" =~ UUID:\ Audio\ Sink ]]; then
        audio=true
      fi
    done < <(bluetoothctl info "${mac}")

    if [[ $connected == true && $audio == true ]]; then
      state_icon="bluetooth.audio"
    fi

    devices+=$(cat <<-JSON
{
  "name":"${name}",
  "mac":"${mac}",
  "connected":${connected},
  "paired":${paired},
  "icon":"${icon}"
},
JSON
)
  done < <(bluetoothctl devices | awk '/Device/ { print $2 }')

  # Strip trailing ","
  if [[ -n $devices ]]; then
    devices="${devices:0:-1}"
  fi

  # Use jq to compact and validate
  jq -c <<-JSON
{
  "icon":"${state_icon}",
  "powered":${powered},
  "discovering":${discovering},
  "devices":[${devices}]
}
JSON
}

# Buffer events. When multiple inputs arrive in quick succession, output only
# the latest.
debounce_events() {
  local line

  while true; do
    read -r line
    if [[ "$line" == *"PropertiesChanged"* ]]; then
      expire=$(( $(date +%s) + 1 ))

      # Flush queue
      while read -t 0.1 -r latest; do
        line=$latest
        [[ $(date +%s) -gt $expire ]] && break
      done

      # Output latest event
      echo "${line}"
    fi
  done
}

handle_event
while read -r line; do
  handle_event
done < <(
  # Watch for state changes.
  dbus-monitor \
    --system \
    "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',sender='org.bluez',arg0='org.bluez.Adapter1'" \
    "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',sender='org.bluez',arg0='org.bluez.Device1'" \
    2>/dev/null \
    | debounce_events
)
