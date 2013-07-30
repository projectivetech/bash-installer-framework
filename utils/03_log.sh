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

  # Pad the severity & debug string.
  local pad=$(printf '%0.1s' " "{1..9})
  local padlength=9
  local severity_str=${severity}$(printf '%*.*s' 0 $((${padlength} - ${#severity})) "${pad}")

  # Important messages and errors go to stdout as well.
  if [ ${severity} == "IMPORTANT" ]; then
    echo -e "\e[00;32m${severity}: ${msg}\e[00m"
  elif [ ${severity} == "ERROR" ]; then
    echo -e "\e[00;31m${severity}: ${msg}\e[00m"
  fi

  # Print to logfile.
  (
    # Print the message.
    echo "[${now} ${severity_str}] $msg"

    # Print additional data.
    while [ $# -ne 0 ]
    do
      echo -e "[----------------- DEBUG^^^^] $1"
      shift
    done
  ) >> ${logfile}
}

function log_init() {
  local now=$(date "+%y%m%d%H%M%S")
  local filename="install.sh.${now}.log"

  dictSet "log" "file" ${filename}
  touch "${filename}"
}

function log_important() {
  assert "$# -ge 1"
  _log "IMPORTANT" "$@"
}

function log_error() {
  assert "$# -ge 1"
  _log "ERROR" "$@"
}

function log_warning() {
  assert "$# -ge 1"
  _log "WARNING" "$@"
}

function log_info() {
  assert "$# -ge 1"
  _log "INFO" "$@"
}
