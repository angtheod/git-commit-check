#!/bin/sh
# [Initialise]
before_run() {
    HEADER="BACKEND SYNTAX"
    COMMAND="php -l -d display_errors=0"
    COMMAND_NAME="PHP"
    COMMAND_VERSION="$(php --version)"
}

# [Execute]
run() {
    FILE_TYPES=".php"
    STAGED_PHP_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep "$FILE_TYPES")
    output=""

    if [ -z "$STAGED_PHP_FILES" ]; then
        warn "$HEADER" "No staged $FILE_TYPES files."
        return
    fi

    shouldFail=0
    tempFile=$(mktemp)

    for PHP_FILE in $STAGED_PHP_FILES; do
        ${COMMAND} ./"$PHP_FILE" >"$tempFile" 2>&1

        exit=$?

        if [ "$exit" -ne 0 ]; then
            shouldFail=1
        fi

        output="$output\n"$(head -n 2 "$tempFile")
    done

    rm "$tempFile"

    if [ "$shouldFail" -ne 0 ]; then
        HAS_SYNTAX_ERRORS=1
        fail "$HEADER" "$output\n"
        return
    fi

    log info "$HEADER" "Pass."

    pass
}
