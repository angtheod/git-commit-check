#!/bin/sh
# [Init]
HEADER="FRONTEND DEPENDENCIES"
COMMAND="npm audit --json --audit-level=low"
REPORT="$GITCC_REPORTS_PATH/package-audit.json"

# [Run]
line2 "$HEADER" "$LOAD_SYMBOL"

${COMMAND} > $REPORT 2>&1

parse_npm_audit "$REPORT"

# Catch a possible network error. Unfortunately, npm audit returns 1 on both successful and failed requests.
if [ -z "$modules" ]; then
    fail "$HEADER" " The request to the npm audit endpoint failed and returned an error!
    See ${BOLD}${REPORT}${NC}"
    return
fi

if [ "$total" -ne 0 ]; then
    warn "$HEADER" " ${MESSAGE_SYMBOL}Critical: (${BRED}${critical}${NC})
    High:     (${RED}${high}${NC})
    Moderate: (${YELLOW}${moderate}${NC})
    Low:      (${GREEN}${low}${NC})\n
    Found ${BOLD}${total}${NC} vulnerabilities in ${BOLD}${modules}${NC} node module(s). Run ${BOLD}npm audit fix${NC} to upgrade those packages.
    See ${BOLD}${REPORT}${NC}"
    return
fi

pass
