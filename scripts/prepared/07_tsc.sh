#!/bin/sh
# [Init]
HEADER="FRONTEND TYPES"
COMMAND="tsc --noEmit"
line2 "$HEADER" "$LOAD_SYMBOL"
add_about_info "TypeScript" "$(tsc --version)"

# [Run]
output=$(${COMMAND} 2>&1)

if [ $? -ne 0 ]; then
    fail "$HEADER" "$output"
    return
fi

log info "$HEADER" "Pass."

pass
