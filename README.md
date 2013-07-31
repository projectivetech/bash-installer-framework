# Installer Framework

This is our new menu-based generic installer framework. See the `tasks` directory for installation task examples, see files in `utils` to get an idea of what you can do wrt. logging, `UI` things, and the like.

## Getting started

Not much to do here, simply copy over `install.sh`, `config.sh` and the `utils` directory to your project, modify the `config.sh` and start creating tasks.

## Tasks

Installer tasks should reside in the `tasks` subdirectory and should be prefixed with a two-digit number (e.g., `00_check_system.sh`), since they are read in and executed in alphanumeric order. Tasks have three states, `NOT RUN`, `FAILED`, and `DONE`. The state is saved persistently across installer runs.

Each task needs to define two functions, `<taskname>_init` and `<taskname>_run`, where `<taskname>` is everything between the two-digit prefix and the `.sh` file extension (e.g., `check_system`). The `init` needs to register the task with the installer framework by calling the `task_setup` function:

    task_setup <taskname> <shortname> <description> [dependencies]

The `run` method should do the hard work and should return `${E_SUCCESS}` on success, `${E_FAILURE}` otherwise. If the task needs to save additional data persistently, it can do so by storing it in its own dictionary by calling `dictSet <taskname> <key> <value>`. For convenience, tasks may define getter functions for their data (see `tasks/03_ganja_smoking.sh` and `tasks/04_his_highness.sh` for example).

Here's a simple example of a task:

    # File: 01_install_packages.sh

    function install_packages_init() {
      task_setup "install_packages" "Install packages" "Install system packages" "check_system"
    }

    function install_packages_run() {
      log_info "Installing packages..."
      
      log_command apt-get install gcc
      if [ $? -ne 0 ]; then
        log_error "Failed to install packages."
        return ${E_FAILURE}
      fi

      return ${E_SUCCESS}
    }

## Utilities

The installer framework provides simple logging and UI utilities:

### Logging

The logging utility lets the user log information to a logfile named `install.sh.<date>.log`. Logging knows six different *severities*, `WARNING`, `INFO`, `IMPORTANT`, `ERROR`, `START`, `FINISH`. The latter two are only used to denote when a task has been started and when it has finished, and they are only used by the framework itself (see `run_task` function in `utils/05_tasks.sh`). The other four may be used as desired by calling their corresponding `log_<severity>` functions. Each function takes at least a message as its first argument, and may be additionally passed arbitrary data which is printed as `DEBUG` information in the logfile.

By default, most of the logging output is printed to `STDOUT` as well, this may be adjusted using the `LOG_STDOUT` configuration variable in `config.sh`.

### UI

Three simple UI functions exist to help the user retrieve information from the customer. Examples:

    if ask "Are you sure?"; then
      ...
    fi

    username=$(enter_variable "Please enter your username: ")
    if [ -z ${username} ]; then
      # The user didn't enter anything! Error out.
    fi

    password=$(enter_hidden_variable "Please enter a password: ")
    ...


