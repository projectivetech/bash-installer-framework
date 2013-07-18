#!/usr/bin/env bash

# Some user interface functionality.

function ask() {
  assert_eq $# 1
  local message=$1

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
}