#!/usr/bin/env bash

function ganja_seeding_init() {
  task_setup "ganja_seeding" "Seeding" "Seed the ganja plants"
}

function ganja_seeding_run() {
  log_info "Seeding some plants..."
  return ${E_SUCCESS}
}
