#!/usr/bin/env bash

function ganja_smoking_init() {
  task_setup "ganja_smoking" "Smoking" "Smoke the weed" "ganja_seeding ganja_farming ganja_harvesting"
}

function ganja_smoking_run() {
  log_info "Puff puff puff..."
  
  if [ -f "two.joints.in.the.morning" ]; then  
    return ${E_SUCCESS}
  else
    log_error "Seems you failed to cut the plants... What should I smoke?"
    return ${E_FAILURE}
  fi
}
