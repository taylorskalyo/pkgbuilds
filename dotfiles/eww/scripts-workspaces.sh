#!/bin/bash

handle_event (){
  local workspaces active_workspace

  workspaces=$(hyprctl -j workspaces \
    | jq -c 'map({id, name, windows}) | sort_by(.id)'
  )
  active_workspace=$(hyprctl monitors -j \
    | jq '.[] | select(.focused) | .activeWorkspace.id'
  )

  jq -c <<-EOF
  {
    "all": ${workspaces},
    "active": ${active_workspace}
  }
EOF
}

handle_event
socat -u "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do
  if [[ $line == "workspacev2"* || $line == "activewindowv2"* || $line == "destroyworkspacev2"* ]]; then
    handle_event
  fi
done
