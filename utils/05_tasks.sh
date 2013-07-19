#!/usr/bin/env bash

# Task-related functionality.

############################## Some globals ###################################

TASKS_DIR="tasks"
TASKS=()

############################## Some constants #################################

T_STATUS_NOT_RUN=1
T_STATUS_FAILED=2
T_STATUS_DONE=3

############################## Some functions #################################

# Converts a status code to a human-readable message.
function status_msg() {
  assert_eq $# 1

  case $1 in
    ${T_STATUS_NOT_RUN})
      msg="NOT RUN"
      ;;
    ${T_STATUS_FAILED})
      msg="FAILED"
      ;;
    ${T_STATUS_DONE})
      msg="DONE"
      ;;
    *)
      assert "false"
      ;;
  esac
  echo ${msg}
}

# Loads the tasks from their files.
function task_load() {
  assert_eq $# 1

  local taskname=$(echo ${task} | sed 's/^[0-9]*\_//' | sed 's/\.sh//')
  local taskfile=${TASKS_DIR}/${task}
  
  # Load task source.
  source ${taskfile} 
  # Run the initialization (creates dictionary, etc.).
  ${taskname}_init
  # Load saved status.
  dictFromFile ${taskname}
  # Append to list of tasks.
  TASKS+=(${taskname})
}

# Setup a task, create variables.
# Example:
# task_setup "name" "shortname" "description"
# task_setup "name" "shortname" "description" "dependencies"
function task_setup() {
  assert "$# -ge 3"
  assert "$# -le 4"

  local task=$1 shortname=$2 description=$3
  dictSet ${task} "shortname" "${shortname}"
  dictSet ${task} "description" "${description}"

  if [ $# -eq 4 ]; then
    local dependencies=$4
    dictSet ${task} "dependencies" "${dependencies}"
  fi

  dictSet ${task} "status" ${T_STATUS_NOT_RUN}
}

# Prints the task status screen.
function tasks_status() {
  assert_eq $# 0

  pad=$(printf '%0.1s' "."{1..80})
  padlength=60
  printf "STATUS:\n"
  printf '%0.1s' "="{1..60}
  printf '\n'
  for task in ${TASKS[@]}
  do
    local description=$(dictGet ${task} "description")
    local statuscode=$(dictGet ${task} "status")
    local status=" ["$(status_msg ${statuscode})"]"
    printf '%s ' "${description}"
    printf '%*.*s' 0 $((${padlength} - ${#description} - 1 - ${#status})) "${pad}"
    printf '%s\n' "${status}"
  done
}

# Iterator function for tasks. 
# Callbacks may return ${FALSE} to stop the iteration, ${TRUE} otherwise.
# Return ${TRUE} if all callback calls succeeded, ${FALSE} otherwise.
function tasks_each() {
  assert_eq $# 1
  assert_function $1
  local func=$1

  for task in ${TASKS[@]}; do
    ${func} ${task}
    if [ $? -eq ${FALSE} ]; then
      return ${FALSE}
    fi
  done

  return ${TRUE}
}

# Returns ${TRUE} if a task has been completed, ${FALSE} otherwise.
function task_done?() {
  assert_eq $# 1
  local task=$1

  if [ $(dictGet ${task} "status") != ${T_STATUS_DONE} ]; then
    return ${FALSE}
  else
    return ${TRUE}
  fi
}

# Returns ${TRUE} if all tasks are done, ${FALSE} otherwise.
function all_tasks_done?() {
  tasks_each "task_done?"
  return $?
}

# Returns ${TRUE} if all dependencies of a task are done, ${FALSE} otherwise.
function all_dependencies_done?() {
  assert_eq $# 1
  local master=$1

  # Does the task specify any dependencies?
  if ! dictIsSet? ${master} "dependencies"; then
    return ${TRUE}
  fi

  local dependencies=$(dictGet ${master} "dependencies")
  for dependency in ${dependencies}; do
    if [ $(dictGet ${dependency} "status") != ${T_STATUS_DONE} ]; then
      return ${FALSE}
    fi
  done

  return ${TRUE}
}

# Set task status to done.
function task_done!() {
  assert_eq $# 1
  local task=$1
  dictSet ${task} "status" ${T_STATUS_DONE}
}

# Set task status to failure.
function task_failed!() {
  assert_eq $# 1
  local task=$1
  dictSet ${task} "status" ${T_STATUS_FAILED}
}

# Runs a tasks and saves the results.
function run_task() {
  assert_eq $# 1
  local task=$1 
  local shortname=$(dictGet ${task} "shortname")

  # Check whether the dependencies are met.
  if ! all_dependencies_done? ${task}; then
    # Ask the user whether he really would like to continue.
    ask "Task ${shortname} has unsatisfied dependencies. Would you really like to run it?"
    if [ $? -eq ${NO} ]; then
      return ${E_FAILURE}
    fi    
  fi

  # Run the task.
  ${task}_run
  local result=$?

  # Save the status.
  dictToFile ${task}

  # At least some output.
  if [ ${result} -ne ${E_SUCCESS} ]; then
    echo $(dictGet ${task} "shortname")" FAILED (see "$(dictGet "log" "file")")"
    return ${E_FAILURE}
  else
    echo $(dictGet ${task} "shortname")" DONE"
    return ${E_SUCCESS}
  fi
}
