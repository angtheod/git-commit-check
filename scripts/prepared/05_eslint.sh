#!/bin/sh
# [Initialise]
before_run() {
    HEADER="FRONTEND SYNTAX"
    FILE_TYPES="ts|tsx|css"
    STAGED_FRONTEND_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep -E '\.('"$FILE_TYPES"')$')
    COMMAND="eslint $STAGED_FRONTEND_FILES --fix"
    COMMAND_NAME="ESLint"
    COMMAND_VERSION="$(eslint --version)"
}

# [Execute]
run() {
    if [ -z "$STAGED_FRONTEND_FILES" ]; then
        warn "$HEADER" " No staged $FILE_TYPES files."
        return
    fi

    output=$($COMMAND 2>&1)

    exit=$?

    if [ "$exit" -ne 0 ]; then
        fail "$HEADER" "$output"
        return
    fi

    log info "$HEADER" "Pass."

    pass
}
