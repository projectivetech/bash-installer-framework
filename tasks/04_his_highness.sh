#!/usr/bin/env bash

function his_highness_init() {
  task_setup "his_highness" "His Highness" "His Royal Highness"
}

function his_highness_run() {
  log_info "Oooh yeah."
  
  teatime=$(enter_variable "Please enter the time." "4:20pm")
  log_important "Ok, the time is ${teatime}!"

  password=$(enter_variable_hidden "Please enter a password.")
  if [ -z ${password} ]; then
    log_error "You really need to enter a password."
    return ${E_FAILURE}
  fi

  # Let's retrieve some data from another task.
  local smoked=$(whatdidismoke)
  log_important "After you smoked ${smoked} you are really baked now."

  return ${E_SUCCESS}
}
