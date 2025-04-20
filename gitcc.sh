#!/bin/sh
# Git Commit Check
# Version: 0.1.0
# Author: Angelos Theodorakopoulos <angtheod@gmail.com>

# Source required scripts
cd "$(dirname "$0")" || exit 1 # Change to the directory of the script
CONFIG="${1:-./config.sh}"
. ./scripts/config.sh
cd "$(dirname "$0")" || exit 1
. ./scripts/lib.sh

line() {
  left="$1"
  right="$2"

  printf "${NC}  %s" "$left"
  fill "$left" "$right"
  printf "${CYAN}%s\n" "$right"
}

line2() {
  left="$1"
  right="$2"

  printf "  %s%s${NC}" "$HEADER_SYMBOL" "$left"
  fill "$left" "$right"
  printf "%s" "$right"
}

line3() {
  left="$1"
  right="$2"
  width="${3:-$WIDTH}"
  filler="${4:-.}"

  printf "%s" "$left"
  fill "$left" "$right" "$width" "$filler"
  printf "%s\n" "$right"
}

header() {
  line3 "╔" "╗" $((WIDTH+8)) "═"

  if [ "$COMPACT" = 0 ]; then
    printf "  %s${CYAN}Load variables\n" "$SECTION_SYMBOL"
    line "Configuration" "$CONFIG"
  fi
}

about() {
  [ "$COMPACT" = 1 ] && return

  printf "\n  %s${CYAN}Display versions\n" "$SECTION_SYMBOL"

  line "$BACKEND_SYNTAX_TOOL" "$BACKEND_SYNTAX_VERSION"
  line "$BACKEND_STANDARDS_TOOL" "$(extract_version "$BACKEND_STANDARDS_VERSION")"
  line "$BACKEND_TESTS_TOOL" "$(extract_version "$BACKEND_TESTS_VERSION")"
  line "$BACKEND_DEPENDENCIES_TOOL" "$(extract_version "$BACKEND_DEPENDENCIES_VERSION")"
  line "$FRONTEND_DEPENDENCIES_TOOL" "$(extract_version "$FRONTEND_DEPENDENCIES_VERSION")"
  line "$FRONTEND_DEPENDENCIES_TOOL_2" "$(extract_version "$FRONTEND_DEPENDENCIES_VERSION_2")"
}

footer() {
  line3 "╚" "╝" $((WIDTH+8)) "═"

  END=$(date +%s)
  time=$((END-START))
  [ $LOG_VIEWER = 1 ] && line3 "$LOG_SYMBOL$LOG_VIEWER_URL" "$TIME_SYMBOL${time}sec" "$((WIDTH+7))" " "
}

check_backend_syntax() {
  [ "$BACKEND_SYNTAX_ENABLED" = 0 ] && return

  header="$BACKEND_SYNTAX_HEADER"
  line2 "$header" "$LOAD_SYMBOL"
  output=""

  if [ "$STAGED_PHP_FILES" != "" ]; then
    shouldFail=0

    tempFile=$(mktemp)
    for PHP_FILE in $STAGED_PHP_FILES; do
      # Using a piped command (but we can't preserve exit status in a POSIX-compliant way)
      # output="$output\n"$(${BACKEND_SYNTAX_COMMAND} ./$PHP_FILE 2>&1 | head -n 2)    # Alternative piped command: sed -n '1p;2p'
      ${BACKEND_SYNTAX_COMMAND} ./"$PHP_FILE" > "$tempFile" 2>&1
      exitStatus=$?
      output="$output\n"$(head -n 2 "$tempFile")

      if [ $exitStatus -ne 0 ]; then
        shouldFail=1
      fi
      FILES="$FILES ./$PHP_FILE"
    done
    rm "$tempFile"

    if [ $shouldFail -ne 0 ]; then
      HAS_SYNTAX_ERRORS=1
      fail "$header" "$output\n"
      return
    fi
  fi

  pass
}

check_backend_standards() {
  [ "$BACKEND_STANDARDS_ENABLED" = 0 ] && return

  header="$BACKEND_STANDARDS_HEADER"
  line2 "$header" "$LOAD_SYMBOL"

  if [ "$STAGED_PHP_FILES" != "" ]; then
    output=$(${BACKEND_STANDARDS_COMMAND} $FILES) # Don't use double quotes for FILES
    if [ $? -ne 0 ]; then
      fail "$header" "$output"
      return
    fi
  fi

  pass
}

check_backend_tests() {
  [ "$BACKEND_TESTS_ENABLED" = 0 ] && return

  header="$BACKEND_TESTS_HEADER"
  line2 "$header" "$LOAD_SYMBOL"

  if [ ! -f "${PWD}/${BACKEND_TESTS_CONFIG}" ]; then
    fail "$header" " ${MESSAGE_SYMBOL}The configuration file ${BOLD}${BACKEND_TESTS_CONFIG}${NC} for tests can not be found"
    return
  fi

  if [ ! -f "${PWD}/${BACKEND_TESTS_ENV}" ]; then
    fail "$header" " ${MESSAGE_SYMBOL}The env file ${BOLD}${BACKEND_TESTS_ENV}${NC} for tests can not be found"
    return
  fi

  if [ "$HAS_SYNTAX_ERRORS" -ne 0 ]; then
    warn "$header" " ${MESSAGE_SYMBOL}Found syntax errors that prevent running tests"
    return
  fi

  output=$(${BACKEND_TESTS_COMMAND})

  if [ $? -ne 0 ]; then
    fail "$header" "$output"
    return
  fi

  pass
}

check_backend_deps() {
  [ "$BACKEND_DEPENDENCIES_ENABLED" = 0 ] && return

  header="$BACKEND_DEPENDENCIES_HEADER"
  line2 "$header" "$LOAD_SYMBOL"

  if (! composer --version | grep -q "2\.[4-9]") > /dev/null 2>&1; then
    fail "$header" " ${MESSAGE_SYMBOL}Composer audit requires version 2.4 or later"
    return
  fi

  output=$(${BACKEND_DEPENDENCIES_COMMAND} > $BACKEND_DEPENDENCIES_AUDIT)

  auditFile=$(cat $BACKEND_DEPENDENCIES_AUDIT)
  advisories=$(printf '%s' "$auditFile" | jq -r '.advisories | length')
  abandoned=$(printf '%s' "$auditFile" | jq -r '.abandoned | length')

  if [ "$abandoned" -ne 0 ]; then
    warn "$header" " ${MESSAGE_SYMBOL}Found ${BOLD}${abandoned}${NC} abandoned composer package(s). See ${BOLD}${BACKEND_DEPENDENCIES_AUDIT}${NC}"
    return
  fi

  if [ "$advisories" -ne 0 ]; then
    warn "$header" " ${MESSAGE_SYMBOL}Found vulnerabilities in ${BOLD}${advisories}${NC} composer package(s). See ${BOLD}${BACKEND_DEPENDENCIES_AUDIT}${NC}"
    return
  fi

  pass
}

check_frontend_deps() {
  [ "$FRONTEND_DEPENDENCIES_ENABLED" = 0 ] && return

  header="$FRONTEND_DEPENDENCIES_HEADER"
  line2 "$header" "$LOAD_SYMBOL"

  output=$(${FRONTEND_DEPENDENCIES_COMMAND} > $FRONTEND_DEPENDENCIES_AUDIT)

  parse_npm_audit "$FRONTEND_DEPENDENCIES_AUDIT"

  if [ "$total" -ne 0 ]; then
    warn "$header" " ${MESSAGE_SYMBOL}Critical: (${BRED}${critical}${NC})
    High:     (${RED}${high}${NC})
    Moderate: (${YELLOW}${moderate}${NC})
    Low:      (${GREEN}${low}${NC})\n
    Found ${BOLD}${total}${NC} vulnerabilities in ${BOLD}${modules}${NC} node module(s). See ${BOLD}${FRONTEND_DEPENDENCIES_AUDIT}${NC}
    Run ${BOLD}npm audit fix${NC} to upgrade those packages"
    return
  fi

  pass
}

pass() {
  sek=$((sek-1))
  printf "\b%s\n" "$PASS_SYMBOL"
}

warn() {
  sek=$((sek-1))
  printf "\b%s\n" "$WARN_SYMBOL"
  message warning "${1}" "${2}"
}

fail() {
  sek=$((sek-1))
  printf "\b%s\n" "$FAIL_SYMBOL"
  message error "${1}" "${2}"
  HAS_ERRORS=1
}

check() {
  [ "$COMPACT" = 0 ] && printf "\n  %s${CYAN}Run checks${NC}\n" "$SECTION_SYMBOL"
  [ "$LOG" = 1 ] && log info "══════════════" ""

  check_backend_syntax
  check_backend_standards
  check_backend_tests
  check_backend_deps
  check_frontend_deps
}

init() {
  START=$(date +%s)
  STAGED_PHP_FILES=`git diff --cached --name-only --diff-filter=ACMR HEAD | grep \\\\.php`
  HAS_SYNTAX_ERRORS=0
  HAS_ERRORS=0
}

main() {
  init
  header
  about
  check
  footer

  if [ "$HAS_ERRORS" -ne 0 ]; then
    exit 1
  fi
}

main

exit $?
