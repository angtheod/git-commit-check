#!/bin/sh
# [Init]
HEADER="BACKEND TESTS"
COMMAND="php artisan test --compact --color=always"
CONFIG="phpunit.xml"
ENV=".env.automated-tests"

# [Run]
line2 "$HEADER" "$LOAD_SYMBOL"

if [ ! -f "${PWD}/${CONFIG}" ]; then
    fail "$HEADER" " ${MESSAGE_SYMBOL}The configuration file ${BOLD}${CONFIG}${NC} for tests can not be found"
    return
fi

if [ ! -f "${PWD}/${ENV}" ]; then
    fail "$HEADER" " ${MESSAGE_SYMBOL}The env file ${BOLD}${ENV}${NC} for tests can not be found"
    return
fi

if [ "$HAS_SYNTAX_ERRORS" -ne 0 ]; then
    warn "$HEADER" " ${MESSAGE_SYMBOL}Found syntax errors that prevent running tests"
    return
fi

output=$(${COMMAND})

if [ $? -ne 0 ]; then
    fail "$HEADER" "$output"
    return
fi

pass
