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

    __parse_npm_audit "$REPORT"
    exit=$?

    # Catch a possible network error. Unfortunately, npm audit returns 1 on both successful and failed requests.
    if [ "$exit" -eq 2 ]; then
        __fail "$HEADER" "  The parsing of the Report file failed. Possible network error!
     See ${BOLD}${REPORT}${NC}"
        return
    fi

    if [ "$total" -ne 0 ]; then
        __warn "$HEADER" "  ${MESSAGE_SYMBOL}Critical: (${BRED}${critical}${NC})
     High:     (${RED}${high}${NC})
     Moderate: (${YELLOW}${moderate}${NC})
     Low:      (${GREEN}${low}${NC})\n
     Found ${BOLD}${total}${NC} vulnerabilities in ${BOLD}${modules}${NC} node module(s). Run ${BOLD}npm audit fix${NC} to upgrade those packages.
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
