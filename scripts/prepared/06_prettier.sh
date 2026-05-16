#!/bin/sh
# [Initialise]
before_run() {
    HEADER="FRONTEND STANDARDS"
    FILE_TYPES="ts|tsx|css"
    STAGED_FRONTEND_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep -E '\.('"$FILE_TYPES"')$')
    COMMAND="prettier --check $STAGED_FRONTEND_FILES"
    COMMAND_NAME="Prettier"
    COMMAND_VERSION="$(prettier --version)"
}

# [Execute]
run() {
    output=$($COMMAND 2>&1)

    exit=$?

    if [ "$exit" -eq 2 ]; then # syntax error
        fail "$HEADER" "$output"
        return
    elif [ "$exit" -eq 1 ]; then # formatting error
        fail "$HEADER" "$output"

        output2=$(prettier --write "$STAGED_FRONTEND_FILES" --log-level silent)

        exit2=$?

        if [ "$exit2" -ne 0 ]; then
            fail "$HEADER" "$output2"
            return
        else
            git add "$STAGED_FRONTEND_FILES"

            MESSAGE="Code format was fixed and changes were staged. Please run this check again."

            printf "   %s\n" "$MESSAGE"
            log info "$HEADER" "$MESSAGE"

            return
        fi
    fi

    log info "$HEADER" "Pass."

    pass
}
