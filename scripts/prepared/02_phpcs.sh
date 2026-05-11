#!/bin/sh
# [Init]
HEADER="BACKEND STANDARDS"
COMMAND="./vendor/bin/phpcs --colors"
line2 "$HEADER" "$LOAD_SYMBOL"

# [Run]
if [ "$HAS_SYNTAX_ERRORS" -ne 0 ]; then
    fail "$HEADER" " ${MESSAGE_SYMBOL}Found syntax errors that block this check."
    return
else
    add_about_info "CodeSniffer" "$(./vendor/bin/phpcs '--version')"
fi

STAGED_PHP_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep .php)

if [ -z "$STAGED_PHP_FILES" ]; then
    warn "$HEADER" "No staged PHP files."
    return
fi

for PHP_FILE in $STAGED_PHP_FILES; do
    FILES="$FILES ./$PHP_FILE"
done

output=$(${COMMAND} $FILES) # Don't use double quotes for FILES

# Don't use double quotes for FILES
if [ $? -ne 0 ]; then
    fail "$HEADER" "$output"
    return
fi

log info "$HEADER" "Pass."

pass
