#!/bin/sh
# [Init]
HEADER="BACKEND TESTS"
COMMAND="php artisan test --compact --color=always"
line2 "$HEADER" "$LOAD_SYMBOL"

# [Run]
CONFIG="phpunit.xml"
ENV=".env.automated-tests"

if [ ! -f "${PWD}/${CONFIG}" ]; then
    fail "$HEADER" " ${MESSAGE_SYMBOL}The configuration file ${BOLD}${CONFIG}${NC} for tests can not be found."
    return
fi

if [ ! -f "${PWD}/${ENV}" ]; then
    fail "$HEADER" " ${MESSAGE_SYMBOL}The env file ${BOLD}${ENV}${NC} for tests can not be found."
    return
fi

if [ "$HAS_SYNTAX_ERRORS" -ne 0 ]; then
    fail "$HEADER" " ${MESSAGE_SYMBOL}Found syntax errors that block this check."
    return
else
    add_about_info "PHPUnit" "$(./vendor/bin/phpunit '--version')"
fi

output=$(${COMMAND})

if [ $? -ne 0 ]; then
    fail "$HEADER" "$output"
    return
fi

log info "$HEADER" "Pass."

pass
