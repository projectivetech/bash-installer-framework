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

  return ${E_SUCCESS}
}
