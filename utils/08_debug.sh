#!/usr/bin/env bash

function enter_debug_console() {
  local prompt="DEBUG \$" line=""
  log_info "Entering debug console..."

  while true; do
    echo -n "DEBUG \$ "
    
    read line
    if [ -z "${line}" ]; then
      echo
      break
    fi
    
    eval "${line}"
  done
}
