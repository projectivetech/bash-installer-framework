#!/usr/bin/env bash

# Some user interface functionality.

YES=${TRUE}
NO=${FALSE}

# Ask the user a yes/no question.
# Returns ${TRUE} for yes, ${FALSE} for no.
# If the user aborts the question by hitting
# Ctrl+D, the return value defaults to no/${FALSE},
# unless otherwise specified in the second parameter.
function ask() {
  assert "$# -ge 1"
  local message=$1
  if [ $# -gt 1 ]; then
    local default=$2
  else
    local default=${FALSE}
  fi

  echo ${message}
  select yn in "Yes" "No"; do
    case ${yn} in
      "Yes")
        return ${TRUE}
        ;;
      "No")
        return ${FALSE}
        ;;
    esac
  done

  # Ctrl-D pressed.
  return ${default}
}

function enter_variable() {
  assert_eq $# 1
  local message=$1
  local var=""

  read -p "${message}" var
  echo ${var}
}

function enter_variable_hidden() {
  assert_eq $# 1
  local message=$1
  local var=""

  read -s -p "${message}" var
  echo ${var}
}
