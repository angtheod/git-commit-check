#!/bin/sh
# [Initialise]
before_run() {
    HEADER="BACKEND DEPENDENCIES"
    COMMAND="composer audit --no-cache --format=json"
    COMMAND_NAME="Composer"
    COMMAND_VERSION="composer --version | head -n 1"
}

# [Execute]
run() {
    if (! composer --version | grep -q "2\.[4-9]") >/dev/null 2>&1; then
        __fail "$HEADER" " ${MESSAGE_SYMBOL}Composer audit requires version 2.4 or later"
        return
    fi

    REPORT="$GITCC_REPORTS_PATH/composer-audit.json"

    ${COMMAND} >"$REPORT" 2>&1

    # Catch a possible network error
    if [ "$?" = "100" ]; then
        __fail "$HEADER" "  This error probably indicates you are offline or have misconfigured DNS resolver(s).
     See ${BOLD}${REPORT}${NC}"
        return
    fi

    auditFile=$(cat "$REPORT")
    advisories=$(printf '%s' "$auditFile" | jq -r '.advisories | length')
    abandoned=$(printf '%s' "$auditFile" | jq -r '.abandoned | length')

    if [ "$abandoned" -ne 0 ]; then
        __warn "$HEADER" "  ${MESSAGE_SYMBOL}Found ${BOLD}${abandoned}${NC} abandoned composer package(s).
     See ${BOLD}${REPORT}${NC}"
        return
    fi

    if [ "$advisories" -ne 0 ]; then
        __warn "$HEADER" "  ${MESSAGE_SYMBOL}Found vulnerabilities in ${BOLD}${advisories}${NC} composer package(s).
     See ${BOLD}${REPORT}${NC}"
        return
    fi

    __log info "$HEADER" "Pass."

    __pass
}
