#!/usr/bin/env bash

function ganja_smoking_init() {
  task_setup "ganja_smoking" "Smoking" "Smoke the weed" "ganja_seeding ganja_farming ganja_harvesting"
}

function ganja_smoking_run() {
  log_info "Puff puff puff..."
  
  if [ -f ./ganja_crop ]; then
    log_command cat ./ganja_crop

    # And a final test of log_command:
    log_command /bin/false
    if [ $? -eq 0 ]; then
      log_error "log_command is broken :-)"
      return ${E_FAILURE}
    fi

    # Let's save some data.
    dictSet "ganja_smoking" "smoked" "two joints"

    return ${E_SUCCESS}
  else
    log_error "Seems you failed to cut the plants... What should I smoke?"
    return ${E_FAILURE}
  fi
}

function whatdidismoke() {
  echo $(dictGet "ganja_smoking" "smoked")
}
