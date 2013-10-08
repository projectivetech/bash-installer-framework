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

# Let the user enter a variable.
# Optionally specify a default value.
function enter_variable() {
  assert_range $# 1 2
  local message=$1
  local var=""

  if [ $# -eq 2 ]; then
    local default=$2

    read -p "${message} [${default}] >> " var

    if [ -z ${var} ]; then
      var=${default}
    fi
  else
    read -p "${message} >> " var
  fi

  echo ${var}
}

# Let the user enter a hidden variable (e.g., password).
function enter_variable_hidden() {
  assert_eq $# 1
  local message=$1
  local var=""

  read -s -p "${message} >> " var
  echo >&2 # Print the newline to stdout explicitly, since read -s gobbles it away.
  echo ${var}
}

# Used to translate messages to user-defined strings.
# TODO: We could also use gettext. But maybe, callbacks are more versatile.
# http://mywiki.wooledge.org/BashFAQ/098
function dispatch_msg() {
  assert_eq $# 1
  local msg=$1

  # Check if the user has defined a callback.
  if [ "$(type -t ${msg})" == "function" ]; then
    ${msg}
  else
    case ${msg} in
      "welcome")
        echo "Welcome!"
        ;;
      "installation_complete")
        echo "Installation complete."
        ;;
      "installation_incomplete")
        echo "Installation incomplete."
        ;;
      "main_menu_prompt")
        echo "What would you like to do today?"
        ;;
      "task_menu_prompt")
        echo "Which one?"
        ;;
      "skip_menu_prompt")
        echo "Which task should be marked to be skipped/unskipped?"
        ;;
    esac
  fi
}
