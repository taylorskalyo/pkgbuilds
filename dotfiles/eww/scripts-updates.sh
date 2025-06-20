#!/bin/bash

set -e
#set -x

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
      if [[ -n $nid ]]; then
        notify-send --replace-id="${nid}" "${summary}" "${body}"
      else
        nids[$type]=$(notify-send --print-id "${summary}" "${body}")
      fi
    fi
  done
}

declare -A cmds=( ["official"]="checkupdates --nocolor" ["AUR"]="paru --color=never -Qu")
declare -A nids=( ["official"]="" ["AUR"]="")

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
