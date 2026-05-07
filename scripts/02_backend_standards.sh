#!/bin/sh
# [Init]
HEADER="BACKEND STANDARDS"
COMMAND="./vendor/bin/phpcs --colors"

# [Run]
line2 "$HEADER" "$LOAD_SYMBOL"

if [ "$STAGED_PHP_FILES" != "" ]; then
    for PHP_FILE in $STAGED_PHP_FILES; do
        FILES="$FILES ./$PHP_FILE"
    done

    output=$(${COMMAND} $FILES) # Don't use double quotes for FILES
    if [ $? -ne 0 ]; then
        fail "$HEADER" "$output"
        return
    fi
fi

pass
