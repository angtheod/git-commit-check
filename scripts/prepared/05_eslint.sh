#!/bin/sh
# [Init]
HEADER="FRONTEND SYNTAX"
STAGED_TS_FILES=$(git diff --cached --name-only --diff-filter=ACMR HEAD | grep -E '\.(ts|tsx|css)$')
COMMAND="eslint $STAGED_TS_FILES --fix"
line2 "$HEADER" "$LOAD_SYMBOL"
add_about_info "ESLint" "$(eslint --version)"

# [Run]
if [ -z "$STAGED_TS_FILES" ]; then
    warn "$HEADER" " No staged TS/TSX files."
    return
fi

output=$($COMMAND 2>&1)
exit=$?

if [ $exit -ne 0 ]; then
    fail "$HEADER" "$output"
    return
fi

log info "$HEADER" "Pass."

pass
