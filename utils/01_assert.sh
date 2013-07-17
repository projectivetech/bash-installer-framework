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

function _backtrace () {
   echo "Backtrace is:"
   i=0
   while caller ${i}
   do
      i=$((i+1))
   done
}

function assert() {
  if [ $# -ne 1 ]
  then
    echo "assert called with wrong number of parameters!"
    _backtrace
    exit $E_PARAM_ERR
  fi

  if [ ! $1 ]
  then
    echo "assert failed: \"$1\""
    _backtrace
    exit $E_ASSERT_FAILED
  fi
}

function assert_eq() {
  if [ $# -ne 2 ]
  then
    echo "assert_eq called with wrong number of parameters!"
    _backtrace
    exit $E_PARAM_ERR
  fi

  assert "${1} -eq ${2}"
}
