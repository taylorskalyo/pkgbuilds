#!/bin/bash

set -e

handle_event() {
  local state=
  local percentage=0
  local remaining=

  acpi_status=$(acpi -b | grep -i "battery ${battery}" || :)
  acpi_regex=": ([[:alpha:][:space:]]+), ([[:digit:]]+)%,? ?([[:digit:]:]+)?"
  if [[ "${acpi_status}" =~ ${acpi_regex} ]]; then
    state=${BASH_REMATCH[1]}
    percentage=${BASH_REMATCH[2]}
    remaining=${BASH_REMATCH[3]}
  fi

  case "${state}" in
    Discharging)
      state="discharging"
      plugged_at=0
      ;;
    Charging)
      state="charging"
      if [[ $plugged_at -eq 0 ]]; then
        plugged_at=$(date +%s)
      fi
      ;;
    Full)
      state="full"
      plugged_at=0
      ;;
    Not\ charging)
      state="plugged"
      if [[ $plugged_at -eq 0 ]]; then
        plugged_at=$(date +%s)
      fi
      ;;
    *)
      state="unknown"
      plugged_at=0
      ;;
  esac

  # Output state
  jq -c <<-JSON
{
  "percentage":${percentage},
  "plugged_at":${plugged_at},
  "remaining":"${remaining}",
  "state":"${state}"
}
JSON
}

# Buffer events. When multiple inputs arrive in quick succession, output only
# the latest.
debounce_events() {
  local line

  while true; do
    read -r line
    if [[ "$line" == *"PropertiesChanged"* ]] ; then
      expire=$(( $(date +%s) + 1 ))

      # Flush fifo
      while read -t 0.5 -r latest; do
        line=$latest
        [[ $(date +%s) -gt $expire ]] && break
      done

      # Output latest event
      echo "${line}"
    fi
  done
}

battery=0
plugged_at=1

handle_event
while read -r line; do
  handle_event
done < <(dbus-monitor --system "path='/org/freedesktop/UPower/devices/battery_BAT${battery}'" | debounce_events)
