#!/usr/bin/env bash

# A little template engine using the erb syntax.

function _templating_read_parameters() {
  local var="" val=""
  while [ $# -gt 0 ]; do
    var=$1
    shift
    if [ $# -eq 0 ]; then
      assert_fail "render_template called with odd number of parameters!"
    fi
    val=$1
    shift

    # Store empty variables in dict.
    if [ -z "${val}" ]; then
      val="__nil"
    fi

    dictSet "render_template" "${var}" "${val}"
  done
}

function _templating_real_render_template() {
  assert_eq $# 2
  local src=$1 dst=$2

  local line="" tok="" var="" val=""
  set -f
  (
    while IFS='' read -r line; do
      while [[ "${line}" =~ (\<%\=[[:blank:]]*([^[:blank:]]*)[[:blank:]]*%\>) ]]; do
        tok=${BASH_REMATCH[1]}
        var=${BASH_REMATCH[2]}

        # Lookup variable (will fail if not set).
        val=$(dictGet "render_template" "${var}")

        # Restore empty variables.
        if [ "${val}" == "__nil" ]; then
          val=""
        fi

        line=${line//${tok}/${val}}
      done

      printf "%s\n" "${line}"
    done < ${src}
  ) > ${dst}
  set +f
}

function render_template_overwrite() {
  assert "$# -ge 2"
  local src=$1 dst=$2
  shift; shift

  assert_file ${src}

  # Read in parameters into dict.
  _templating_read_parameters "$@"

  # Render!
  _templating_real_render_template ${src} ${dst}

  # Clean dictionary.
  dictClean "render_template"
}

function render_template() {
  assert "$# -ge 2"
  local src=$1 dst=$2
  shift; shift

  assert_file ${src}

  if [ -e ${dst} ]; then
    assert_file ${dst}

    if ! ask "Configuration file ${dst} already exists. Should it be overwritten?"; then
      return
    fi
  fi

  # Read in parameters into dict.
  _templating_read_parameters "$@"

  # Render!
  _templating_real_render_template ${src} ${dst}

  # Clean dictionary.
  dictClean "render_template"
}



