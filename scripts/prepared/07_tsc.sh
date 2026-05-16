#!/bin/sh
# [Initialise]
before_run() {
    HEADER="FRONTEND TYPES"
    COMMAND="tsc --noEmit"
    COMMAND_NAME="TypeScript"
    COMMAND_VERSION="$(tsc --version)"
}

# [Execute]
run() {
    output=$(${COMMAND} 2>&1)

    exit=$?

    if [ "$exit" -ne 0 ]; then
        fail "$HEADER" "$output"
        return
    fi

    log info "$HEADER" "Pass."

    pass
}
