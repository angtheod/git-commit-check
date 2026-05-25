#!/bin/sh
# [Initialise]
before_run() {
    HEADER="BACKEND TESTS"
    COMMAND="php artisan test --compact --color=always"
    COMMAND_NAME="PHPUnit"
    COMMAND_VERSION="./vendor/bin/phpunit --version"
}

# [Execute]
run() {
    CONFIG="phpunit.xml"
    ENV=".env.automated-tests"

    if [ ! -f "${PWD}/${CONFIG}" ]; then
        __fail "$HEADER" "  ${MESSAGE_SYMBOL}The configuration file ${BOLD}${CONFIG}${NC} for tests can not be found."
        return
    fi

    if [ ! -f "${PWD}/${ENV}" ]; then
        __fail "$HEADER" "  ${MESSAGE_SYMBOL}The env file ${BOLD}${ENV}${NC} for tests can not be found."
        return
    fi

    if [ "$HAS_SYNTAX_ERRORS" -ne 0 ]; then
        __fail "$HEADER" "  ${MESSAGE_SYMBOL}Found syntax errors that block this check."
        return
    fi

    __run
}

# [Finalise]
after_run() {
    __add_about_info "Laravel" "php artisan --version"
}
