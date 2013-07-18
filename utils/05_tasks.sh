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
function load_task() {
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

# Prints the task status screen.
function task_status() {
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

# Returns $TRUE if all tasks are done, false otherwise.
function all_tasks_done?() {
  for task in ${TASKS[@]}
  do
    if [ $(dictGet ${task} "status") != ${T_STATUS_DONE} ]; then
      return ${FALSE}
    fi
  done
  return ${TRUE}
}

# Returns $TRUE if all dependencies of a task are done, false otherwise.
function all_dependencies_done?() {
  assert_eq $# 1
  local master=$1

  # Does the task specify any dependencies?
  dictIsSet? ${master} "dependencies"
  if [ $? -eq ${FALSE} ]; then
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

# Runs a tasks and saves the results.
function run_task() {
  assert_eq $# 1

  local task=$1 
  local shortname=$(dictGet ${task} "shortname")

  # Check whether the dependencies are met.
  all_dependencies_done? ${task}
  if [ $? -eq ${FALSE} ]; then
    # Ask the user whether he really would like to continue.
    ask "Task ${shortname} has unsatisfied dependencies. Would you really like to run it?"
    if [ $? -eq ${FALSE} ]; then
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
