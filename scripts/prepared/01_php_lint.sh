#!/bin/sh
# [Init]
HEADER="BACKEND SYNTAX"
COMMAND="php -l -d display_errors=0"
line2 "$HEADER" "$LOAD_SYMBOL"
add_about_info "PHP" "$(php -r 'echo phpversion();')"

# [Run]
STAGED_PHP_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep .php)
output=""

if [ -z "$STAGED_PHP_FILES" ]; then
    warn "$HEADER" "No staged PHP files."
    return
fi

shouldFail=0
tempFile=$(mktemp)

for PHP_FILE in $STAGED_PHP_FILES; do
    ${COMMAND} ./"$PHP_FILE" > "$tempFile" 2>&1
    exitStatus=$?
    output="$output\n"$(head -n 2 "$tempFile")

    if [ $exitStatus -ne 0 ]; then
        shouldFail=1
    fi
done

rm "$tempFile"

if [ "$shouldFail" -ne 0 ]; then
    HAS_SYNTAX_ERRORS=1
    fail "$HEADER" "$output\n"
    return
else
    add_about_info "Laravel" "$(php artisan --version)"
fi

log info "$HEADER" "Pass."

pass
