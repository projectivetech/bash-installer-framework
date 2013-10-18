#!/usr/bin/env bash

# Error codes.

E_SUCCESS=0
E_FAILURE=1

# Boolean values.
TRUE=0
FALSE=1

# Array functions.

# Test if array contains an element.
# Call like: if array_contains? "a string" "${array[@]}"; then ...
# Credit: http://stackoverflow.com/questions/3685970/bash-check-if-an-array-contains-a-value
function array_contains? () {
  for e in "${@:2}"; do 
    [[ "$e" == "$1" ]] && return ${TRUE}; 
  done
  return ${FALSE}
}
