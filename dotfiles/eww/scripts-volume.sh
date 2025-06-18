#!/bin/bash

set -e

handle_event() {
  local out in

  out=$(get_volume @DEFAULT_SINK@)
  in=$(get_volume @DEFAULT_SOURCE@)

  jq -c <<-JSON
{
  "out": ${out},
  "in": ${in}
}
JSON
}

get_volume() {
  local id=$1

  read -r _ volume mute < <(wpctl get-volume "${id}") || {
    echo "{}" ; return 0
  }

  # Decimal to percentage
  volume=${volume//./}
  volume=${volume##+(0)}

  # String to boolean
  if [[ -n $mute ]]; then
    mute=true
  else
    mute=false
  fi

  cat <<-JSON
{
  "percentage": ${volume},
  "mute": ${mute}
}
JSON
}

handle_event

# Watch for state changes.
while read -r line; do
  if [[ "$line" == *"change"* ]]; then
    handle_event
  fi
done < <(pactl subscribe 2>/dev/null)
