#!/bin/sh
cd "$PROJECT_PATH" || exit

ABOUT=""
DELIMITER="<>"

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

  printf "  %s%s${NC}" "$HEADER_SYMBOL " "$left"
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

# Concatenate the Left/Right strings to the about section data.
add_about_info() {
  ABOUT_LEFT="$1"
  ABOUT_RIGHT="$2"

  if [ -z "$ABOUT" ]; then
    ABOUT="$ABOUT_LEFT|$ABOUT_RIGHT"
  else
    ABOUT="$ABOUT$DELIMITER$ABOUT_LEFT|$ABOUT_RIGHT"
  fi
}

# Split the about section data into strings that can be used to generate a new line in the about section.
split_about_info() {
  printf '%s\n' "$ABOUT" | tr -s "$DELIMITER" '\n'
}

# Return 1 if the 2nd argument contains the 1st argument. Return 0 otherwise.
contains_string() {
  _string="$2"
  _substring="$1"

  case "$_string" in
  *"$_substring"*)
    return 0  # Found
    ;;
  *)
    return 1  # Not found
    ;;
  esac
}

# Extract the version of an application from a command output.
extract_version() {
  if [ $# -eq 0 ]; then
    printf "(Unknown)\n"
    return 1
  fi

  version=$(printf "%s" "$1" | sed -n '
      # Match either:
      # 1. Version numbers preceded by /
      # 2. A "v" followed by version numbers after non-digit
      # 3. Version numbers preceded by non-digit
      # 4. Version numbers at string start
      s/^.*\/\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
      t
      s/^.*[^0-9]v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
      t
      s/^.*[^0-9]\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
      t
      s/^v\{0,1\}\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
    ')

  if [ -z "$version" ]; then
    printf "(Unknown)\n"
    return 1
  fi

  printf "%s" "$version"
}

# Fill a line in the terminal with $4 chars until it reaches $WIDTH in length (including the left and right side).
fill() {
  left="$1"
  right="$2"
  width="${3:-$WIDTH}"
  filler="${4:-.}"

  usedLength=$(printf "%s%s" "$left" "$right" | wc -m)
  fillerLength=$((width - usedLength))

  i=0
  while [ "$i" -lt "$fillerLength" ]; do
    printf "%s" "$filler"
    i=$((i + 1))
  done
}

# Parse the output of npm audit and provide concise information.
parse_npm_audit() {
  if [ $# -eq 0 ]; then
    printf "Error: No input file specified"
    printf "Usage: %s npm-report.json" "$0"
    exit 1
  fi

  auditFile=$(cat "$1")
  modules=$(printf '%s' "$auditFile" | jq -r '.vulnerabilities | length')
  critical=$(printf '%s' "$auditFile" | jq -r .metadata.vulnerabilities.critical)
  high=$(printf '%s' "$auditFile" | jq -r .metadata.vulnerabilities.high)
  moderate=$(printf '%s' "$auditFile" | jq -r .metadata.vulnerabilities.moderate)
  low=$(printf '%s' "$auditFile" | jq -r .metadata.vulnerabilities.low)
  total=$(printf '%s' "$auditFile" | jq -r .metadata.vulnerabilities.total)
}

# Create a Log file entry according to config value LOG_FORMAT and redirects to config value LOG_FILE
log() {
  level="$1"
  header="$2"
  message="$3"
  logFile="${4:-${LOG_FILE}}"

  case "$level" in  # Validate log level
  info|warning|error)
    ;;
  *)
    printf "Invalid log level: %s. Must be info, warning, or error" "$level" >&2
    return 1
    ;;
  esac

  dateTime=$(date "+%Y-%m-%d %H:%M:%S")

  logEntry=$(printf "$LOG_FORMAT" "$dateTime" "${level}" "${header}" "$message")

  # Pass log output from sed to remove control chars and color codes
  printf "%s\n" "$(printf "%s" "$logEntry" | sed -e "s/\x1b\[.\{1,5\}m//g")" >> "$logFile"
}

message() {
  level="$1"
  titleOrText="$2"
  text="$3"

  if [ "$#" -eq 2 ] && [ "$SHOW_OUTPUT" = 1 ]; then
    printf "   %s\n" "$titleOrText"
  fi

  if [ "$#" -eq 3 ]; then
    [ "$SHOW_OUTPUT" = 1 ] && printf "   $text\n"
    [ "$LOG" = 1 ] && log "$level" "$titleOrText" "$text"
  fi
}

pass() {
  sek=$((sek-1))
  printf "\b%s\n" "$PASS_SYMBOL"
  [ -n "$1" ] && message info "${1}" "${2}"
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
