#!/usr/bin/env bash

function ganja_smoking_init() {
  dictSet "ganja_smoking" "status" ${T_STATUS_NOT_RUN}
  dictSet "ganja_smoking" "shortname" "Smoking"
  dictSet "ganja_smoking" "description" "Smoke the weed"
  dictSet "ganja_smoking" "dependencies" "ganja_seeding ganja_farming ganja_harvesting"
}

function ganja_smoking_run() {
  log_info "Puff puff puff..."
  
  if [ -f "two.joints.in.the.morning" ]; then  
    dictSet "ganja_smoking" "status" ${T_STATUS_DONE}
    return ${E_SUCCESS}
  else
    log_error "Seems you failed to cut the plants... What should I smoke?"
    dictSet "ganja_smoking" "status" ${T_STATUS_FAILED}
    return ${E_FAILURE}
  fi
}
