#!/bin/sh
# [Initialise]
before_run() {
    HEADER="FRONTEND DEPENDENCIES"
    COMMAND="npm audit --json --audit-level=low"
    COMMAND_NAME="NPM"
    COMMAND_VERSION="npm --version"
}

# [Execute]
run() {
    REPORT="$GITCC_REPORTS_PATH/package-audit.json"

    ${COMMAND} > "$REPORT" 2>&1

    # Npm audit returns 1 on both successful and failed requests, so we can't check for network error.

    if ! __parse_npm_audit "$REPORT"; then
        return
    fi

    if [ "$total" -ne 0 ]; then
        __warn "$HEADER" "  ${MESSAGE_SYMBOL}Critical: (${BRED}${critical}${NC})
     High:     (${RED}${high}${NC})
     Moderate: (${YELLOW}${moderate}${NC})
     Low:      (${GREEN}${low}${NC})
     Found ${BOLD}${total}${NC} vulnerabilities in ${BOLD}${modules}${NC} node module(s).
     See ${BOLD}${REPORT}${NC}"
        return
    fi

    __log info "$HEADER" "Pass."

    __pass
}

# [Finalise]
after_run() {
    __add_about_info "Node" "node --version"
}
