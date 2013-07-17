############################## Some globals ###################################

UTILS_DIR="utils"
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

# Runs a tasks and saves the results.
function run_task() {
  assert_eq $# 1

  local task=$1

  # Run the task.
  ${task}_run
  local result=$?

  # Save the status.
  dictToFile ${task}

  # At least some output.
  if [ ${result} -ne ${E_SUCCESS} ]; then
    echo "FAILED (see "$(dictGet "log" "file")"...)"
    return ${E_FAILURE}
  else
    echo "DONE"
    return ${E_SUCCESS}
  fi
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

# Automatic installation.
function run_installation() {
  for task in ${TASKS[@]}
  do
    # Already completed?
    if [ $(dictGet ${task} "status") -eq ${T_STATUS_DONE} ]; then
      continue
    fi

    run_task ${task}

    if [ $? -ne ${E_SUCCESS} ]; then
      return ${E_FAILURE}
    fi
  done

  echo "ALL DONE"
  return ${E_SUCCESS}
}

############################## Main app #######################################

# Some initial checks

# TODO: Check for bash + version.
# TODO: Check for root.
# TODO: Check for every utility we need (date, grep, sed, awk, ...).

# Load our utility modules.
for util in `ls -1 ${UTILS_DIR}`
do
  source ${UTILS_DIR}/${util}
done

# Initialize the logfile.
log_init

# Read in tasks.
log_info "Loading tasks..."
for task in `ls -1 ${TASKS_DIR}`
do
  load_task ${task}
done

# Read command line arguments.
log_info "Reading command line arguments..."
if [ $# -ge 1 ]
then
  
  # TODO: Automatic installation.
  echo "TODO"

else

  # Print the status.
  task_status

  # Give the user a nice looping main menu!
  options=("Continue the installation")
  for task in ${TASKS[@]}
  do
    shortname=$(dictGet ${task} "shortname")
    options+=("${shortname}")
  done
  options+=("Exit (Ctrl+D)")

  # Main menu loop.
  printf "\nWhat would you like to do today:\n"
  select opt in "${options[@]}"
  do
    if [ "${opt}" =  "Continue the installation" ]; then
      run_installation
      task_status
    elif [ "${opt}" = "Exit (Ctrl+D)" ]; then
      exit ${E_SUCCESS}
    else
      for task in ${TASKS[@]}
      do
        if [ "${opt}" = $(dictGet ${task} "shortname") ]; then
          run_task ${task}
          task_status
        fi
      done
    fi
  done

fi
