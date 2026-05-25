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
        __fail "$HEADER" " ${MESSAGE_SYMBOL}Composer audit requires composer version 2.4 or later."
        return
    fi

    REPORT="$GITCC_REPORTS_PATH/composer-audit.json"

    ${COMMAND} > "$REPORT" 2>&1

    # Check for network error.
    if [ "$?" = "100" ]; then
        __fail "$HEADER" "  This error probably indicates you are offline or have misconfigured DNS resolver(s).
     See ${BOLD}${REPORT}${NC}"
        return
    fi

    if ! __parse_composer_audit "$REPORT"; then
        return
    fi

    if [ "$abandoned" -ne 0 ] || [ "$advisories" -ne 0 ]; then
        message=""

        if [ "$advisories" -ne 0 ]; then
            message="$message  ${MESSAGE_SYMBOL}Found ${BOLD}${advisoryIds}${NC} vulnerabilities in ${BOLD}${advisories}${NC} composer package(s)."
        fi

        if [ "$abandoned" -ne 0 ]; then
            message="$message\n     ${MESSAGE_SYMBOL}Found ${BOLD}${abandoned}${NC} abandoned composer package(s)."
        fi

        message="$message\n     See ${BOLD}${REPORT}${NC}"

        __warn "$HEADER" "$message"

        return
    fi

    __log info "$HEADER" "Pass."

    __pass
}
