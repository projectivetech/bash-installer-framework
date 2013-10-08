#!/usr/bin/env bash

# A basic assert utility for sanity checks.
#
# Examples:
#
# function foo() {
#   # We need exactly two parameters.
#   assert_eq $# 2
# }
#
# function bar() {
#   # We need at least two parameters.
#   assert "$# -ge 2"
# }

# To exit immediately from a subshell, we need to
# send a custom signal (in this case, SIGUSR1) to the top-most 
# parent process, and call exit from there.
# This is necessary when, for instance, dictGet is called
# in a subshell (like $(dictGet "dict" "key")).
trap "exit ${E_FAILURE}" USR1
TOP_PID=$$

function _backtrace() {
  echo "backtrace is:"
  i=0
  while caller ${i}
  do
    i=$((i+1))
  done
}

function _assert_fail() {
  # Print assert errors to stderr!
  echo "assert failed: \"$1\"" >&2
  _backtrace >&2

  # And crash immediately.
  kill -s USR1 ${TOP_PID}
}

function assert() {
  if [ $# -ne 1 ]
  then  
    _assert_fail "assert called with wrong number of parameters!"
  fi

  if [ ! $1 ]
  then
    _assert_fail $1
  fi
}

function assert_not() {
  if [ $# -ne 1 ]
  then
    _assert_fail "assert_not called with wrong number of parameters!"
  fi

  if [ $1 ]
  then
    _assert_fail $1
  fi
}

function assert_variable_exists() {
  if [ $# -ne 1 ]
  then
    _assert_fail "assert_variable_exists called with wrong number of parameters!"
  fi

  local gvar=$1
  if [[ -z ${!gvar} ]]; then
    _assert_fail "variable ${gvar} isn't set"
  fi
}

function assert_eq() {
  if [ $# -ne 2 ]
  then
    _assert_fail "assert_eq called with wrong number of parameters!"
  fi

  assert "${1} -eq ${2}"
}

function assert_range() {
  if [ $# -ne 3 ]
  then
    _assert_fail "assert_range called with wrong number of parameters!"
  fi

  assert "${1} -ge ${2} -a ${1} -le ${3}"
}

function assert_function() {
  if [ $# -ne 1 ]
  then
    _assert_fail "assert_function called with wrong number of parameter!"
  fi

  local func=$1
  assert "\"$(type -t ${func})\" == \"function\""
}
