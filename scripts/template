#!/bin/sh
# TODO: [MUST implement] function 'before_run'. Fill in the values for the following variables.
before_run() {
    HEADER="MY HEADER"
    COMMAND="my_command"
    COMMAND_NAME="My Command"
    COMMAND_VERSION="my_command --version"
}

# [MAY implement] function 'run' with custom logic which overrides default function '__run'.
run() {
    # custom logic ...

    __run # MAY call the default '__run' function which will execute the command and handle the output.
}

# [MAY implement] function 'after_run' to perform post-check actions.
after_run() {
    # MAY call the 'add_about_info' function multiple times to print multiple lines in the about section.
    __add_about_info "command2 name" "command2 --version"
}
