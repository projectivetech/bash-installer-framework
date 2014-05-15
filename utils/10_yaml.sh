#!/usr/bin/env bash

# Read values from YAML files using Ruby.

function yaml_get() {
  assert "$# -ge 2"
  local ymlfile=$1
  shift

  local script="puts YAML.load(File.read('$ymlfile'))$(printf "['%s']" "$@")"
  ruby -ryaml -e "${script}"
}
