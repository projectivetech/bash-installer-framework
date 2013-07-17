#!/usr/bin/env bash

function ganja_farming_init() {
  dictSet "ganja_farming" "status" ${T_STATUS_NOT_RUN}
  dictSet "ganja_farming" "shortname" "Growing"
  dictSet "ganja_farming" "description" "Grow the ganja plants"
}

function ganja_farming_run() {
  log_info "Watering the plants..."
  
  dictSet "ganja_farming" "status" ${T_STATUS_DONE}
  return ${E_SUCCESS}
}
