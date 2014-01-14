#!/usr/bin/env sh

# Semantic Versioning comparison utils.
#
# (c) by Cloudflare
# https://github.com/cloudflare/semver_bash

function _semver_part() {
  assert_eq $# 2
  local semver=$1
  local part=$2

  local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)' 
  echo ${semver} | sed -e "s#${RE}#\\${part}#"
}

function semver_major() {
  assert_eq $# 1
  local semver=$1

  _semver_part ${semver} 1
}

function semver_minor() {
  assert_eq $# 1
  local semver=$1

  _semver_part ${semver} 2
}

function semver_patch() {
  assert_eq $# 1
  local semver=$1

  _semver_part ${semver} 3
}

function semver_eq() {
  assert_eq $# 2
  local semver1=$1 semver2=$2

  if [ $(semver_major ${semver1}) != $(semver_major ${semver2}) ]; then
    return ${FALSE}
  elif [ $(semver_minor ${semver1}) != $(semver_minor ${semver2}) ]; then
    return ${FALSE}
  elif [ $(semver_patch ${semver1}) != $(semver_patch ${semver2}) ]; then
    return ${FALSE}
  fi

  return ${TRUE}
}

function semver_lt() {
  assert_eq $# 2
  local semver1=$1 semver2=$2

  if [ $(semver_major ${semver2}) -gt $(semver_major ${semver1}) ]; then
    return ${TRUE}
  elif [ $(semver_major ${semver2}) -eq $(semver_major ${semver1}) ]; then
    if [ $(semver_minor ${semver2}) -gt $(semver_minor ${semver1}) ]; then
      return ${TRUE}
    elif [ $(semver_minor ${semver2}) -eq $(semver_minor ${semver1}) ]; then
      if [ $(semver_patch ${semver2}) -gt $(semver_patch ${semver1}) ]; then
        return ${TRUE}
      fi
    fi
  fi

  return ${FALSE}
}

function semver_gt() {
  assert_eq $# 2
  local semver1=$1 semver2=$2

  if semver_lt ${semver1} ${semver2}; then
    return ${FALSE}
  elif semver_eq ${semver1} ${semver2}; then
    return ${FALSE}
  fi
  
  return ${TRUE}
}
