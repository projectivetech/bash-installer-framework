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

  return ${E_SUCCESS}
}
