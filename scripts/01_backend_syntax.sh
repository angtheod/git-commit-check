#!/bin/sh
# [Init]
HEADER="BACKEND SYNTAX"
COMMAND="php -l -d display_errors=0"

# [Run]
line2 "$HEADER" "$LOAD_SYMBOL"
output=""

if [ "$STAGED_PHP_FILES" != "" ]; then
    shouldFail=0
    tempFile=$(mktemp)

    for PHP_FILE in $STAGED_PHP_FILES; do
        # Using a piped command (but we can't preserve exit status in a POSIX-compliant way)
        # output="$output\n"$(${COMMAND} ./$PHP_FILE 2>&1 | head -n 2)    # Alternative piped command: sed -n '1p;2p'
        ${COMMAND} ./"$PHP_FILE" > "$tempFile" 2>&1
        exitStatus=$?
        output="$output\n"$(head -n 2 "$tempFile")

        if [ $exitStatus -ne 0 ]; then
            shouldFail=1
        fi
        FILES="$FILES ./$PHP_FILE"
    done

    rm "$tempFile"

    if [ "$shouldFail" -ne 0 ]; then
        HAS_SYNTAX_ERRORS=1
        fail "$HEADER" "$output\n"
        return
    fi
fi

pass
