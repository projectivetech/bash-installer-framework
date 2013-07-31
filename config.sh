# User configuration.
#
# This file should contain the product-specific configuration.
# For example, one may overwrite default global configuration
# values such as ROOT_ONLY.
# Plus, one should define the three greeter functions 'welcome',
# 'installation_complete', and 'installation_incomplete'.

# Set to 1 to enforce root installations.
#ROOT_ONLY=1

# Overwrite default utils & tasks directories.
#UTILS_DIR=${INSTALLER_PATH}/data/utils
#TASKS_DIR=${INSTALLER_PATH}/data/tasks

# Overwrite default log-to-stdout config.
#LOG_STDOUT=( "IMPORTANT" "ERROR" "INFO" "WARNING" )

function welcome() {
  echo -e "\e[00;32mWelcome to the new and shiny installer framework!\e[00m"
}

function installation_complete() {
  echo -e "\e[00;32mMove along now, there's nothing else you can do!\e[00m"

  # If you want the install script to terminate automatically:
  #exit 0
}

function installation_incomplete() {
  echo -e "\e[00;31mWhoopsie!\e[00m"
}
