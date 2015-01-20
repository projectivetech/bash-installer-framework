#!/usr/bin/env bash

function ganja_seeding_init() {
  task_setup "ganja_seeding" "Seeding" "Seed the ganja plants"

  settings_init ".settings"
}

function ganja_seeding_skip() {
  log_info "ganja_seeding_skip called"
}

function ganja_seeding_run() {
  log_info "Seeding some plants..."

  settings_set "somesetting" "somevalue"

  return ${E_SUCCESS}
}
