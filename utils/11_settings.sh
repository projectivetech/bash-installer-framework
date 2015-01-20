#!/usr/bin/env bash

# Global settings utils for persistent (over installer runs) installer
# configuration (i.e., user choices to be remembered for updates).

function settings_init() {
  assert_eq $# 1
  INSTALLER_SETTINGS_FILE="$1"
  _settings_load
}

function settings_set() {
  assert_eq $# 2
  _assert_settings_initialized
  local key=$1
  local val=$2
  dictSet "_settings" "${key}" "${val}"
  _settings_save
}

function settings_get() {
  assert_eq $# 1
  _assert_settings_initialized
  local key=$1

  compgen -a variable | grep settings

  if dictIsSet? "_settings" "${key}"; then
    dictGet "_settings" "${key}"
  fi

  # Else echo nothing.
}

function _settings_load() {
  dictFromFile "_settings" "${INSTALLER_SETTINGS_FILE}"
}

function _settings_save() {
  dictToFile "_settings" "${INSTALLER_SETTINGS_FILE}"
}

function _assert_settings_initialized() {
  if [ -z "${INSTALLER_SETTINGS_FILE}" ]; then
    assert_fail "settings not initialized"
  fi
}

