############################## Global constants ###############################

# TODO: This is bad.
# First, $SUDO_USER may not be set depending on the sudo version installed on
# the resp. OS. Second, we should better adapt the failing line 13 to work
# a different way.
if [ ! -z ${SUDO_USER} ]; then
  echo "Please run the script as root, not via sudo."
  exit 1
fi

# Path to install script, no matter from where it is called.
INSTALLER_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

############################## Default configuration ##########################

# Set to 1 to allow only the root user to execute the script.
ROOT_ONLY=0

# Path to installer utils.
UTILS_DIR=${INSTALLER_PATH}/utils

# Path to installer tasks.
TASKS_DIR=${INSTALLER_PATH}/tasks

# User configuration file.
USER_CONFIG=${INSTALLER_PATH}/config.sh

# Array of log severity values that go both to stdout and the logfile.
LOG_STDOUT=( "ERROR" "IMPORTANT" "WARNING" "INFO" "SKIP" "START" "FINISH" )

############################## User configuration #############################

if [ -f ${USER_CONFIG} ]; then
  source ${USER_CONFIG}
fi

############################## Initial checks #################################

# bash => 3.
if [ -z ${BASH} ]; then
  echo "Please run the script using the bash interpreter"
  exit 1
else
  bash_major_version=${BASH_VERSION:0:1}
  if [ ${bash_major_version} -lt 3 ]; then
    echo "Please run the script using bash version 3 or greater"
    exit 1
  fi
fi

# root.
if [ ${ROOT_ONLY} -gt 0 ] && [ ${USER} != "root" ]; then
  echo "Please run the script as root user"
  exit 1
fi

# Tools.
grep -V >/dev/null 2>&1 || { echo "Please install 'grep'"; exit 1; }
sed --version >/dev/null 2>&1 || { echo "Please install 'sed'"; exit 1; }
date --version >/dev/null 2>&1 || { echo "Please install 'date'"; exit 1; }

############################## Some functions #################################

# Automatic installation.
function run_installation() {
  tasks_each "run_installation_task"
  
  if all_tasks_done?; then
    dispatch_msg "installation_complete"
    return ${E_SUCCESS}
  else
    dispatch_msg "installation_incomplete"
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

function main_menu() {
  # Print the welcome message.
  dispatch_msg "welcome"

  # Print the status.
  tasks_status

  # Give the user a nice looping main menu!
  local options=( "Run the installation" "Skip/Unskip task" "Run single task" "Exit (Ctrl+D)")

  echo -e "\n$(dispatch_msg "main_menu_prompt")"
  select opt in "${options[@]}"; do
    if [ "${opt}" == "Run the installation" ]; then
      run_installation
      tasks_status
    elif [ "${opt}" == "Skip/Unskip task" ]; then
      skip_task_menu
      tasks_status
    elif [ "${opt}" == "Run single task" ]; then
      single_task_menu
      tasks_status
    elif [ "${opt}" == "Exit (Ctrl+D)" ]; then
      exit ${E_SUCCESS}
    fi
  done
}

function _select_task_menu() {
  assert_eq $# 2
  assert_function $1
  local func=$1 prompt=$2

  local options=()
  for task in ${TASKS[@]}
  do
    shortname=$(dictGet ${task} "shortname")
    options+=("${shortname}")
  done
  options+=("Nevermind (Ctrl+D)")

  echo -e "\n$(dispatch_msg ${prompt})"
  select opt in "${options[@]}"; do
    if [ "${opt}" == "Nevermind (Ctrl+D)" ]; then
      return ${E_SUCCESS}
    else
      for task in ${TASKS[@]}
      do
        if [ "${opt}" = "$(dictGet ${task} "shortname")" ]; then
          ${func} ${task}
          return $?
        fi
      done
    fi
  done

  return ${E_SUCCESS}  
}

function skip_task_menu() {
  _select_task_menu "skip_unskip_task" "skip_menu_prompt"
  return $?
}

function single_task_menu() {
  _select_task_menu "run_task" "task_menu_prompt"
  return $?
}

############################## Main app #######################################

# Load our utility modules.
for util in `ls -1 ${UTILS_DIR}`; do
  source ${UTILS_DIR}/${util}
done

# Initialize the logfile.
log_init

# Read in tasks.
log_info "Loading tasks..."
for task in `ls -1 ${TASKS_DIR}`
do
  task_load ${task}
done

# Add autorun command line option.
add_command_line_switch "run" "run" "r" "Run the installation automatically"
add_command_line_switch "help" "help" "h" "Show this usage information"
add_command_line_switch "debug" "debug" "d" "Enter debug console (for development)"

# Read command line arguments.
log_info "Reading command line arguments..."
process_command_line_options "$@"
if [ $? -ne ${E_SUCCESS} ] || has_command_line_switch? "help"; then
  usage
  exit ${E_FAILURE}
fi

if has_command_line_switch? "debug"; then

  # Debug console.
  enter_debug_console

elif has_command_line_switch? "run"; then

  # Automatic installation.
  run_installation

else

  # User-driven installation.
  main_menu

fi

exit 0
