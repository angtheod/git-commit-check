#!/bin/sh
# [Init]
HEADER="FRONTEND BUILD"
COMMAND="vite build"
line2 "$HEADER" "$LOAD_SYMBOL"
add_about_info "Vite" "$(vite --version)"

# [Run]
output=$(${COMMAND} 2>&1)

if [ $? -ne 0 ]; then
    fail "$HEADER" "$output"
    return
fi

log info "$HEADER" "$output"

pass
