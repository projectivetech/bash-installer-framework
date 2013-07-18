############################## Some functions #################################

function welcome() {
  echo "Welcome."
}

function installation_complete() {
  echo "Installation complete."
}

function installation_incomplete() {
  echo "Installation incomplete."
}

# Automatic installation.
function run_installation() {
  tasks_each "run_installation_task"

  all_tasks_done?
  if [ $? -eq ${TRUE} ]; then
    installation_complete
    return ${E_SUCCESS}
  else
    installation_incomplete
    return ${E_FAILURE}
  fi
}

function run_installation_task() {
  local task=$1

  # Already completed?
  if [ $(dictGet ${task} "status") -eq ${T_STATUS_DONE} ]; then
    return ${TRUE}
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

############################## Main app #######################################

# Some initial checks

# TODO: Check for bash + version.
# TODO: Check for root.
# TODO: Check for every utility we need (date, grep, sed, awk, ...).

# Print the welcome message.
welcome

# Load our utility modules.
UTILS_DIR="utils"
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
  
  # TODO: Fully Automatic installation.
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
