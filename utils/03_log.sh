#!/usr/bin/env bash

# A basic logging utility.
#
# Examples:
#
# log_error "An error happened."
# log_warning "Unsupported OS" $OS

function _color_code() {
  assert_eq $# 1
  local severity=$1 color="\e[00m"

  case ${severity} in
    "IMPORTANT")
      color="\e[00;32m"
      ;;
    "ERROR")
      color="\e[00;31m"
      ;;
    "INFO")
      color="\e[00;35m"
      ;;
    "WARNING")
      color="\e[01;33m"
      ;;
  esac

  echo "${color}"
}

function _log_to_stdout?() {
  assert_eq $# 1
  local severity=$1
  
  for s in "${LOG_STDOUT[@]}"; do
    if [ ${s} == ${severity} ]; then
      return ${TRUE}
    fi
  done

  return ${FALSE}
}

function _log() {
  assert "$# -ge 2"
  local severity=$1 msg="$2" now=$(date "+%y/%m/%d %H:%M:%S") logfile=$(dictGet "log" "file")
  shift; shift

  # Pad the severity & debug string.
  local pad=$(printf '%0.1s' " "{1..9})
  local padlength=9
  local severity_str=${severity}$(printf '%*.*s' 0 $((${padlength} - ${#severity})) "${pad}")

  # Check if we should also log to stdout.
  if _log_to_stdout? ${severity}; then
    local uncolor="\e[0;00m"
    local color=$(_color_code ${severity})
    echo -e "${color}${severity}: ${msg}${uncolor}"
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
