#!/bin/bash

set -e

handle_event() {
  local knob=$1
  local value=$2

  load_config

  # Adjust settings
  case $knob in
    brightness)
      value=$(( value < brightness_min ? brightness_min : value ))
      value=$(( value > brightness_max ? brightness_max : value ))
      if [[ $brightness != "$value" ]]; then

        # Scale auto brightness bounds to match
        local delta=$(( value - brightness ))
        brightness_low=$(bc <<<"scale=0; (${brightness_low} + (1 - ${ambient_light}) * ${delta}) / 1")
        brightness_high=$(bc <<<"scale=0; (${brightness_high} + ${ambient_light} * ${delta}) / 1")
        echo "brightness_low: ${brightness_low}" >&2
        echo "brightness_high: ${brightness_high}" >&2

        brightness=$value
        "${brightness_cmd[@]}" "${brightness}" 1>&2
      fi
      ;;
    lightsensor)
      ambient_light=$value

      # Calculate brightness within bounds
      value=$(bc <<<"scale=0; (${brightness_low} + ${ambient_light} * (${brightness_high} - ${brightness_low})) / 1")
      value=$(( value < brightness_min ? brightness_min : value ))
      value=$(( value > brightness_max ? brightness_max : value ))
      if [[ $brightness != "$value" ]]; then
        brightness=$value
        "${brightness_cmd[@]}" "${brightness}" 1>&2
      fi
      ;;
    temperature)
      if [[ $temperature != "$value" ]]; then
        case $value in
          day)   temperature=$temperature_high   ;;
          night) temperature=$temperature_low ;;
          *)
            value=$(( value < temperature_min ? temperature_min : value ))
            value=$(( value < temperature_max ? temperature_max : value ))
            temperature=$value
            ;;
        esac
        "${temperature_cmd[@]}" "${temperature}" 1>&2
      fi
      ;;
  esac

  save_config

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

save_config() {
  cat <<-ENV > "${config_file}"
temperature_auto=${temperature_auto}
temperature=${temperature}
temperature_low=${temperature_low}
temperature_high=${temperature_high}

brightness_auto=${brightness_auto}
brightness=${brightness}
brightness_low=${brightness_low}
brightness_high=${brightness_high}
ENV
}

load_config() {
  if [[ -f "${config_file}" ]]; then
    # shellcheck source=/dev/null
    source "${config_file}"
  fi
}

# Use sunrise / sunset to set temperature
temperature_daemon() {
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

# Use ambient light sensor to set brightness
brightness_daemon() {
  local search_path="/sys/bus/iio/devices/iio:device"
  local sensor_dir

  sensor_dir=$(dirname "$(realpath "${search_path}"*/in_illuminance_raw 2>/dev/null)")
  if [[ $sensor_dir == "." ]]; then
    return 0
  else
    echo "using light sensor at ${sensor_dir}" >&2
  fi

	local file_raw="${sensor_dir}/in_illuminance_raw"
	local file_offset="${sensor_dir}/in_illuminance_offset"
	local file_scale="${sensor_dir}/in_illuminance_scale"

  local lux_max=500
  local lux_min=1

  while [[ -f ${file_raw} ]]; do
    local sensor_raw sensor_offset sensor_scale
    sensor_raw=$(< "${file_raw}")
    sensor_offset=$(< "${file_offset}")
    sensor_scale=$(< "${file_scale}")

    local lux
    lux=$(bc <<< "${sensor_scale} * (${sensor_raw} + ${sensor_offset})")
    if (( $(bc <<< "${lux} > 0") )); then
      if (( $(bc <<< "${lux} < ${lux_min}") )); then
        lux=$lux_min
      elif (( $(bc <<< "${lux} > ${lux_max}") )); then
        lux=$lux_max
      fi

      local value
      value=$(bc -l <<<"(l($lux) - l($lux_min)) / (l($lux_max) - l($lux_min))")

      echo "lightsensor ${value}" >> "${fifo}"
    fi

    sleep 5
  done
}

daemon() {
  if [[ ! -p "${fifo}" ]]; then
    mkfifo "${fifo}"
  fi
  trap 'rm -f "${fifo}"; exit 0' INT EXIT

  load_config
  if [[ $temperature_auto == true ]]; then
    temperature_daemon &
  fi
  if [[ $brightness_auto == true ]]; then
    brightness_daemon &
  fi

  while read -r knob value; do
    handle_event "${knob}" "${value}"
  done < <(tail -f "${fifo}" | debounce_events)

  wait
}

weather_url="https://weather.com/weather/today"

temperature_auto=true
temperature=6500
temperature_low=2850
temperature_high=6500
temperature_cmd=(hyprctl hyprsunset temperature)
temperature_min=2850
temperature_max=6500

ambient_light="1.0"
brightness_auto=true
brightness=100
brightness_low=0
brightness_high=100
brightness_cmd=(hyprctl hyprsunset gamma)
brightness_min=50
brightness_max=100

if command -v brightnessctl; then
  brightness_cmd=(brightnessctl set)
fi

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
config_file="${config_dir}/eww/screenrc"
fifo=/tmp/eww_screen.fifo

knob=$1
value=$2
if [[ -n $knob ]] && [[ -n $value ]]; then
  echo "${knob} ${value}" >> "${fifo}"
else
  daemon
fi
