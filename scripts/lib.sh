#!/bin/sh
cd "$PROJECT_PATH" || exit

extract_version() {
  if [ $# -eq 0 ]; then
    printf "(Unknown)\n"
    return 1
  fi

  version=$(printf "%s" "$1" | sed -n '
    # Match either:
    # 1. A "v" followed by version numbers after non-digit
    # 2. Version numbers preceded by non-digit
    # 3. Version numbers at string start
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

# Fills a line in the terminal with $4 chars until it reaches $WIDTH in length
# (including the left and right side lengths).
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

# Creates a Log entry according to config value LOG_FORMAT and redirects to config value LOG_FILE
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
#  logEntry="[${dateTime}] local.${level}: ${header}
#  Message: ${message}"

  # Pass log output from sed to remove control chars and color codes
  printf "%s\n" "$(printf "%s" "$logEntry" | sed -e "s/\x1b\[.\{1,5\}m//g")" >> "$logFile"
}

message() {
  level="$1"
  titleOrText="$2"
  text="$3"

  if [ "$#" -eq 2 ] && [ "$COMPACT" = 0 ]; then
    printf "   %s\n" "$titleOrText"
  fi
  if [ "$#" -eq 3 ]; then
    [ "$COMPACT" = 0 ] && printf "   $text\n"
    [ "$LOG" = 1 ] && log "$level" "$titleOrText" "$text"
  fi
}
