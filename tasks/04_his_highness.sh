#!/usr/bin/env bash

function his_highness_init() {
  task_setup "his_highness" "His Highness" "His Royal Highness"
}

function his_highness_run() {
  log_info "Oooh yeah."
  
  password=$(enter_variable_hidden "Please enter a password: ")
  if [ -z ${password} ]; then
    log_error "You really need to enter a password."
    return ${E_FAILURE}
  fi

  log_important "You are really baked now. This line goes to both stdout and the logfile."

  return ${E_SUCCESS}
}
