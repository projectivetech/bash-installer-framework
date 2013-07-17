#!/usr/bin/env bash

# A basic dictionary type for bash 3 (bash 4 has one).
#
# Example:
#
# dictSet "foo" "bar" "baz"
# var = $(dictGet "foo" "bar")
# echo ${var}
# dictToFile "foo" "foo.sh"

function dictSet() {
  assert_eq $# 3
  local dict=$1 key=$2 value=$3
  eval "${dict}_${key}=\"$value\""
}

function dictGet() {
  assert_eq $# 2
  local dict=$1 key=$2
  local value="${dict}_${key}"
  printf '%s' "${!value}"
}

function dictToFile() {
  assert_eq $# 1
  local dict=$1
  local file=".${dict}.status"
  local keys=$(compgen -A variable | grep ${dict})

  # Print all variables to files.
  (
    echo "#!/usr/bin/env bash"
    for key in $keys
    do
      echo "${key}=\"${!key}\""
    done
  ) > $file
}

function dictFromFile() {
  assert_eq $# 1
  local dict=$1
  local file=".${dict}.status"

  # Read the status file if existent.
  if [ -e ${file} ]; then
    source ${file}
  fi
}
