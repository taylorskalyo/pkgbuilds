#!/bin/bash

set -e

to_table() {
  printf "<tt>"
  ( printf "Package Installed Available\n"; cat ) | column -t
  printf "</tt>"
}

to_count() {
  grep -c '^'
}

handle_event() {
  for type in "${!cmds[@]}"; do
    local cmd=${cmds[$type]}
    local nid=${nids[$type]}
    local icon=${icons[$type]}

    local updates
    updates=$(${cmd} | grep -vF '[ignored]' | sed 's/->//')

    if [[ -z $updates ]] && [[ -n ${nid} ]]; then
      dbus-send --session --dest=org.freedesktop.Notifications --type=method_call /org/freedesktop/Notifications org.freedesktop.Notifications.CloseNotification uint32:"${nid}"
      nids[$type]=
    elif [[ -n $updates ]]; then
      local count
      count=$(to_count <<<"${updates}")

      local summary="${count} ${type} update(s) available"
      local body

      body=$(to_table <<<"${updates}")
      local notifyargs=(--app-name="${type}-updates" --icon="${icon}" --hint=int:recolor:1 "${summary}" "${body}")
      if [[ -n $nid ]]; then
        notify-send --replace-id="${nid}" "${notifyargs[@]}"
      else
        nids[$type]=$(notify-send --print-id "${notifyargs[@]}")
      fi
    fi
  done
}

declare -A cmds=( ["official"]="checkupdates --nocolor" ["AUR"]="paru --color=never -Qu")
declare -A nids=( ["official"]="" ["AUR"]="")
declare -A icons=( ["official"]="$(realpath icons/install-desktop.svg)" ["AUR"]="$(realpath icons/deployed-code-update.svg)")

while read -r line; do
  if [[ "$line" == *"transaction completed"* ]] || [[ "$line" == "poll" ]]; then
    handle_event
  fi
done < <(

  # Watch for state changes.
  tail -f /var/log/pacman.log &

  # Poll periodically.
  while true; do
    echo "poll"
    sleep 3600
  done &
)

wait
