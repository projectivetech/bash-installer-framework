#!/usr/bin/env bash

function ganja_seeding_init() {
  dictSet "ganja_seeding" "status" ${T_STATUS_NOT_RUN}
  dictSet "ganja_seeding" "shortname" "Seeding"
  dictSet "ganja_seeding" "description" "Seed the ganja plants"
  dictSet "ganja_seeding" "dependencies" ""
}

function ganja_seeding_run() {
  log_info "Seeding some plants..."
  
  dictSet "ganja_seeding" "status" ${T_STATUS_DONE}
  return ${E_SUCCESS}
}
