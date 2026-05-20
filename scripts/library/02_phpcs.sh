#!/bin/sh
# [Initialise]
before_run() {
    HEADER="BACKEND STANDARDS"
    COMMAND="./vendor/bin/phpcs --colors"
}

# [Execute]
run() {
    if [ "$HAS_SYNTAX_ERRORS" -ne 0 ]; then
        __fail "$HEADER" "  ${MESSAGE_SYMBOL}Found syntax errors that block this check."
        return
    else
        COMMAND_NAME="CodeSniffer"
        COMMAND_VERSION="./vendor/bin/phpcs --version"
    fi

    STAGED_PHP_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep .php)

    if [ -z "$STAGED_PHP_FILES" ]; then
        __warn "$HEADER" " No staged PHP files."
        return
    fi

    for PHP_FILE in $STAGED_PHP_FILES; do
        FILES="$FILES ./$PHP_FILE"
    done

    output=$(${COMMAND} $FILES) # Don't use double quotes for FILES

    exit=$?

    if [ "$exit" -ne 0 ]; then
        __fail "$HEADER" "$output"
        return
    fi

    __log info "$HEADER" "Pass."

    __pass
}
