#!/usr/bin/env bash

function ganja_farming_init() {
  task_setup "ganja_farming" "Growing" "Grow the ganja plants" "ganja_seeding"
}

function ganja_farming_run() {
  log_info "Watering the plants..."

  # Let's test semantic versioning here.
  log_info "Major part of 10.20.30 is "$(semver_major 10.20.30)
  
  if semver_gt "1.2.10" "1.2.2"; then
    log_info "1.2.10 is greater than 1.2.2! Yeehaa."
  fi

  return ${E_SUCCESS}
}
