#!/usr/bin/env bash

function ganja_harvesting_init() {
  dictSet "ganja_harvesting" "status" ${T_STATUS_NOT_RUN}
  dictSet "ganja_harvesting" "shortname" "Harvesting"
  dictSet "ganja_harvesting" "description" "Harvest the ganja plants"
  dictSet "ganja_harvesting" "dependencies" "ganja_seeding ganja_farming"
}

function ganja_harvesting_run() {
  log_info "Cutting the plants..."

  if [ -f "scissors" ]; then
    dictSet "ganja_harvesting" "status" ${T_STATUS_DONE}
    return ${E_SUCCESS}
  else
    log_error "Missing scissors. Please touch the scissors."
    dictSet "ganja_harvesting" "status" ${T_STATUS_FAILED}
    return ${E_FAILURE}
  fi
}
