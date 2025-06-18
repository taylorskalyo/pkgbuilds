#!/bin/bash

set -e

handle_event() {
  local knob=$1
  local value=$2

  # Adjust settings
  case $knob in
    brightness)
      brightness=$value
      "${brightness_cmd[@]}" "${brightness}" 1>&2
      ;;
    temperature)
      case $value in
        day)   temperature=$temperature_day   ;;
        night) temperature=$temperature_night ;;
        *)     temperature=$value             ;;
      esac
      "${temperature_cmd[@]}" "${temperature}" 1>&2
      ;;
  esac

  # Output state
  jq -c <<-JSON
{
  "brightness":${brightness},
  "temperature":${temperature}
}
JSON
}

# Buffer events. When multiple inputs arrive in quick succession, output only
# the latest.
debounce_events() {
  local line

  while true; do
    read -r line
    expire=$(( $(date +%s) + 1 ))

    # Flush fifo
    while read -t 0.1 -r latest; do
      line=$latest
      [[ $(date +%s) -gt $expire ]] && break
    done

    # Output latest event
    echo "${line}"
  done
}

temperature_auto() {
  while true; do
    local now times sunrise sunset delay

    times=$(
      (
        curl -s -L "${weather_url}" \
          | grep -o -i 'sunchart.*[0-9]\{1,2\}:[0-9]\{2\} [a|p]m' \
          | grep -io '[0-9]\{1,2\}:[0-9]\{2\} [a|p]m' \
          || printf "6:00am\n6:00pm\n"
        ) \
      | xargs -I{} date --date='{}' +%s \
    )
    read -r sunrise sunset <<< "${times//$'\n'/ }"
    now=$(date +%s)

    if [[ $now -lt $sunrise ]]; then
      echo "temperature night" >> "${fifo}"
      delay=$(( sunrise - now ))
    elif [[ $now -lt $sunset ]]; then
      echo "temperature day" >> "${fifo}"
      delay=$(( sunset - now ))
    else
      echo "temperature night" >> "${fifo}"
      delay=$(( sunrise + 24 * 60 * 60 - now ))
    fi

    sleep "${delay}"
  done
}

daemon() {
  mkfifo "${fifo}"
  trap 'rm -f "${fifo}"; exit 0' INT EXIT

  temperature_auto &

  while read -r knob value; do
    handle_event "${knob}" "${value}"
  done < <(tail -f "${fifo}" | debounce_events)

  wait
}

weather_url="https://weather.com/weather/today"

temperature_day=6500
temperature_night=5500
temperature=6500
temperature_cmd=(hyprctl hyprsunset temperature)

brightness=100
brightness_cmd=(hyprctl hyprsunset gamma)
if command -v brightnessctl; then
  brightness_cmd=(echo brightnessctl set)
fi

fifo=/tmp/eww_screen.fifo

knob=$1
value=$2
if [[ -n $knob ]] && [[ -n $value ]]; then
  echo "${knob} ${value}" >> "${fifo}"
else
  daemon
fi
