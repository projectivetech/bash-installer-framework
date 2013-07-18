#!/usr/bin/env bash

# A basic logging utility.
#
# Examples:
#
# log_error "An error happened."
# log_warning "Unsupported OS" $OS

function _log() {
  assert "$# -ge 2"
  local severity=$1 msg="$2" now=$(date "+%y/%m/%d %H:%M:%S") logfile=$(dictGet "log" "file")
  shift; shift

  (
    # Print the message.
    echo "[$now $severity] $msg"

    # Print additional data.
    while [ $# -ne 0 ]
    do
      echo -e "[----------------- DEBUG^^] $1"
      shift
    done
  ) >> "${logfile}"
}

function log_init() {
  local now=$(date "+%y%m%d%H%M%S")
  local filename="install.sh.${now}.log"

  dictSet "log" "file" ${filename}
  touch "${filename}"
}

function log_error() {
  assert "$# -ge 1"
  _log "ERROR  " "$@"
}

function log_warning() {
  assert "$# -ge 1"
  _log "WARNING" "$@"
}

function log_info() {
  assert "$# -ge 1"
  _log "INFO   " "$@"
}
