#!/usr/bin/env bash

function come_down_init() {
  task_setup "come_down" "Come down" "Come down slowly"
}

function come_down_run() {
  log_info "Too bad, it's over."
  
  # Didn't want to put this file into scm :-)
  cat > template_file <<EOF
Lalala
This is a <%= test %>.
With <%=multiple%> <%=   statements  %> in a line.
Even an <%= empty %> variable.
EOF

  render_template "template_file" "render_file" "test" "success" "multiple" "more than one" "statements" "variables" "empty" ""

  cat > second_template_file <<EOF
This file has been written at <%= timestamp %>.
EOF

  render_template_overwrite "second_template_file" "ts_current_run" "timestamp" "$(date)"
  render_template_no_overwrite "second_template_file" "ts_first_run" "timestamp" "$(date)"

  return ${E_SUCCESS}
}
