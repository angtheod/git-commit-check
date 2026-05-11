#!/bin/sh
# [Init]
HEADER="FRONTEND STANDARDS"
COMMAND="prettier --check resources/"
line2 "$HEADER" "$LOAD_SYMBOL"
add_about_info "Prettier" "$(prettier --version)"

# [Run]
output=$($COMMAND 2>&1)
exit=$?

if [ $exit -ne 0 ]; then
    fail "$HEADER" "$output"

    output2=$(prettier --write resources/ --log-level silent)
    exit2=$?
    if [ $exit2 -ne 0 ]; then
        fail "$HEADER" "$output2"
        return
    fi

    STAGED_TS_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep -E '\.(ts|tsx|css)$')

    git add $STAGED_TS_FILES

    MESSAGE="Formatting fixed and changes staged. Please try 'git commit' again!"
    printf "   %s\n" "$MESSAGE"
    log info "$MESSAGE" ""

    return
fi

log info "$HEADER" "Pass."

pass
