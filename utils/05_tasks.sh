#!/usr/bin/env bash

# Task-related functionality.

############################## Some globals ###################################

TASKS=()

############################## Some constants #################################

T_STATUS_NOT_RUN=1
T_STATUS_FAILED=2
T_STATUS_DONE=3
T_STATUS_SKIP=4

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
    ${T_STATUS_SKIP})
      msg="SKIP"
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

# Returns ${TRUE} if a task has been marked to be skipped, ${FALSE} otherwise.
function task_skip?() {
  assert_eq $# 1
  local task=$1

  if [ $(dictGet ${task} "status") == ${T_STATUS_SKIP} ]; then
    return ${TRUE}
  else
    return ${FALSE}
  fi
}

# Returns ${TRUE} if a task has been completed, ${FALSE} otherwise.
function task_done?() {
  assert_eq $# 1
  local task=$1

  if [ $(dictGet ${task} "status") -eq ${T_STATUS_DONE} ]; then
    return ${TRUE}
  else
    return ${FALSE}
  fi
}

# Returns ${TRUE} if a task has been completed or marked to be skipped, ${FALSE} otherwise.
function task_done_or_skipped?() {
  assert_eq $# 1
  local task=$1

  if [ $(dictGet ${task} "status") == ${T_STATUS_DONE} ] || [ $(dictGet ${task} "status") == ${T_STATUS_SKIP} ]; then
    return ${TRUE}
  else
    return ${FALSE}
  fi
}

# Returns ${TRUE} if all tasks are done, ${FALSE} otherwise.
function all_tasks_done?() {
  tasks_each "task_done_or_skipped?"
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

# Retrieve the status of a task a human-readable text.
function task_status_msg() {
  assert_eq $# 1
  local task=$1
  local status=$(dictGet ${task} "status")
  status_msg ${status}
}

# Set task status to skip.
function task_skip!() {
  assert_eq $# 1
  local task=$1
  dictSet ${task} "status" ${T_STATUS_SKIP}
}

# Set task status to not run.
function task_not_run!() {
  assert_eq $# 1
  local task=$1
  dictSet ${task} "status" ${T_STATUS_NOT_RUN}
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

# Prints the task status screen.
function tasks_status() {
  assert_eq $# 0

  local pad=$(printf '%0.1s' "."{1..80})
  local padlength=60
  
  printf "STATUS:\n"
  printf '%0.1s' "="{1..60}
  printf '\n'
  for task in ${TASKS[@]}
  do
    local description=$(dictGet ${task} "description")
    local status=" ["$(task_status_msg ${task})"]"
    printf '%s ' "${description}"
    printf '%*.*s' 0 $((${padlength} - ${#description} - 1 - ${#status})) "${pad}"
    printf '%s\n' "${status}"
  done
}

# Marks a task to be skipped.
function skip_unskip_task() {
  assert_eq $# 1
  local task=$1

  if task_skip? ${task}; then
    task_not_run! ${task}
  else
    task_skip! ${task}
  fi

  # Save the skip.
  dictToFile ${task}
  
  return ${E_SUCCESS}
}

# Runs a tasks and saves the results.
function run_task() {
  assert_eq $# 1
  local task=$1
  local shortname=$(dictGet ${task} "shortname")

  # Check whether the dependencies are met.
  if [ ${TASK_DEPENDENCY_CHECKING} -gt 0 ]; then
    if ! all_dependencies_done? ${task}; then
      # Ask the user whether he really would like to continue.
      ask "Task ${shortname} has unsatisfied dependencies. Would you really like to run it?"
      if [ $? -eq ${NO} ]; then
        return ${E_FAILURE}
      fi
    fi
  fi

  # Log the task run.
  log_task_start ${task}

  # Run the task.
  ${task}_run
  local result=$?

  # Update the status.
  if [ ${result} -ne ${E_SUCCESS} ]; then
    task_failed! ${task}
  else
    task_done! ${task}
  fi

  # Log the result.
  log_task_finish ${task}

  # Save the status.
  dictToFile ${task}

  return ${result}
}

function run_or_skip_task() {
  local task=$1

  if task_done_or_skipped? ${task}; then
    # Run skip method to setup stuff in subsequent installer runs.
    if [ "$(type -t ${task}_skip)" == "function" ]; then
      ${task}_skip
    fi

    if task_skip? ${task}; then
      log_task_skip ${task}
    fi

    return ${E_SUCCESS}
  fi

  run_task ${task}

  # Failure?
  if [ $? -ne ${E_SUCCESS} ]; then
    # Ask the user whether she would like to skip the failed task.
    ask "Would you like to continue with the installation anyway?"
    return $?
  else
    return ${TRUE}
  fi
}

function run_all_tasks() {
  tasks_each "run_or_skip_task"
}
