#!/bin/sh
cd "$PROJECT_PATH" || exit

ABOUT=""
DELIMITER="<>"

__get_current_shell() {
    if [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$KSH_VERSION" ]; then
        echo "ksh"
    elif [ -n "$FISH_VERSION" ]; then
        echo "fish"
    else # Fallback method
        ps -p $$ -o comm= 2>/dev/null || echo "(Unknown)"
    fi
}

__line() {
    left="$1"
    right="$2"

    printf "${NC}  %s" "$left"
    __fill "$left" "$right"
    printf "${CYAN}%s\n" "$right"
}

__line2() {
    left="$1"
    right="$2"

    printf "  %s$CYAN%s${NC}" "$HEADER_SYMBOL  " "$left"
    __fill "$left  " "$right"
    printf "%s" "$right"
}

__line3() {
    left="$1"
    right="$2"
    width="${3:-$WIDTH}"
    filler="${4:-.}"

    printf "%s" "$left"
    __fill "$left" "$right" "$width" "$filler"
    printf "%s\n" "$right"
}

# Concatenate the Left/Right strings to the about section data.
__add_about_info() {
    ABOUT_LEFT="$1"
    ABOUT_RIGHT="$2"

    if [ -z "$ABOUT" ]; then
        ABOUT="$ABOUT_LEFT|$ABOUT_RIGHT"
    else
        ABOUT="$ABOUT$DELIMITER$ABOUT_LEFT|$ABOUT_RIGHT"
    fi
}

# Split the about section data into strings that can be used to generate a new line in the about section.
__split_about_info() {
    # The trailing newline ensures 'while read' receives the last segment.
    printf "%s\n" "$(printf '%s' "$ABOUT" | tr -s "\n" ' ' | tr -s "$DELIMITER" '\n')"
}

# Return 1 (error command code) if 1st arg is Found within 2nd arg, but it is preceded with a '#',
# else return 0 (success command code) if 1st arg is Found within 2nd arg,
# else return 1 (error command code) if 1st arg is Not Found within 2nd arg.
__contains_string() {
    _substring="$1"
    _string="$2"

    case "$_string" in
    *"#${_substring}"*)
        return 1  # Found but starts with '#', so it's disabled.
        ;;
    *"$_substring"*)
        return 0  # Found.
        ;;
    *)
        return 1  # Not found.
        ;;
    esac
}

# Extract the version of an application from a command output.
__extract_version() {
    if [ $# -eq 0 ]; then
        printf "(Unknown)\n"
        return 1
    fi

    version=$(printf "%s" "$1" | sed -n '
      # Stop after first match using "q" command
      # Match either:
      # 1. Version numbers preceded by /
      s/^.*\/\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
      t found
      # 2. A "v" followed by version numbers after non-digit
      s/^.*[^0-9]v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
      t found
      # 3. Version numbers preceded by non-digit
      s/^.*[^0-9]\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
      t found
      # 4. Version numbers at string start
      s/^v\{0,1\}\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p
      t found
      b
      :found
      q
    ')

    if [ -z "$version" ]; then
        printf "(Unknown)\n"
        return 1
    fi

    printf "%s" "$version"
}

# Fill a line in the terminal with $4 chars until it reaches $WIDTH in length (including the left and right side).
__fill() {
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
__parse_npm_audit() {
    if [ $# -eq 0 ]; then
        printf "Error: No input file specified"
        printf "Usage: %s npm-report.json" "$0"
        exit 1
    fi

    auditFile=$(cat "$1")

    # Check if the input file contains a valid JSON or not.
    if ! printf '%s' "$auditFile" | jq empty 2>/dev/null; then
        return 2
    fi

    modules=$(printf '%s' "$auditFile" | jq -r '.vulnerabilities | length // 0')
    critical=$(printf '%s' "$auditFile" | jq -r '.metadata.vulnerabilities.critical // 0')
    high=$(printf '%s' "$auditFile" | jq -r '.metadata.vulnerabilities.high // 0')
    moderate=$(printf '%s' "$auditFile" | jq -r '.metadata.vulnerabilities.moderate // 0')
    low=$(printf '%s' "$auditFile" | jq -r '.metadata.vulnerabilities.low // 0')
    total=$(printf '%s' "$auditFile" | jq -r '.metadata.vulnerabilities.total // 0')
}

__before_run() {
    if [ $# -eq 0 ]; then
        printf "(Unknown)\n"
        return 1
    fi

    script=$1

    # Initialise variables.
    HEADER=""
    COMMAND_NAME=""
    COMMAND_VERSION=""

    . "$script"

    before_run # Call user's before run function.

    __line2 "$HEADER" "$LOAD_SYMBOL"
}

# Execute the user-defined $COMMAND, hold the output, and check the exit code.
# If the command failed, then call __fail with either a proper message OR the command's output.
# If the command succeeded, then create an info log entry and call __pass with a message to show (if available).
__run() {
    output=$(${COMMAND} 2>&1)

    exit=$?

    if [ "$exit" -eq 127 ]; then
        __fail "$HEADER" "  $COMMAND_NAME not found."
        return
    elif [ "$exit" -ne 0 ]; then
        __fail "$HEADER" "$output"
        return
    fi

    __log info "$HEADER" "$output"

    __pass "$@"
}

# Execute post-check actions (e.g., add a line in the about section).
__after_run() {
    if [ "$COMMAND_NAME" != "" ] && [ "$COMMAND_VERSION" != "" ]; then
        __add_about_info "$COMMAND_NAME" "$COMMAND_VERSION"
    fi
}

# Create a Log file entry according to config value LOG_FORMAT and redirects to config value LOG_FILE
__log() {
    level="$1"
    header="$2"
    message="$3"
    logFile="${4:-${LOG_FILE}}"

    case "$level" in  # Validate log level
    info|warning|error)
        ;;
    *)
        printf "  Invalid log level: %s. Must be info, warning, or error.\n" "$level" >&2
        return 1
        ;;
    esac

    dateTime=$(date "+%Y-%m-%d %H:%M:%S")

    logEntry=$(printf "$LOG_FORMAT" "$dateTime" "${level}" "${header}" "$message")

    # Pass log output from sed to remove control chars and color codes
    printf "%s\n" "$(printf "%s" "$logEntry" | sed -e "s/\x1b\[.\{1,5\}m//g")" >> "$logFile"
}

__message() {
    level="$1"
    titleOrText="$2"
    text="$3"

    if [ "$#" -eq 2 ] && [ "$SHOW_OUTPUT" = 1 ]; then
        printf "   %s\n" "$titleOrText"
    fi

    if [ "$#" -eq 3 ]; then
        [ "$SHOW_OUTPUT" = 1 ] && printf "   $text\n"
        [ "$LOG" = 1 ] && __log "$level" "$titleOrText" "$text"
    fi
}

__pass() {
    sek=$((sek-1))
    printf "\b%s\n" "$PASS_SYMBOL"
    [ -n "$1" ] && __message info "${1}" "${2}"

    if [ -z "$2" ] || [ "$SHOW_OUTPUT" -eq 0 ]; then
        printf "\n"
    fi
}

__warn() {
    sek=$((sek-1))
    printf "\b%s\n" "$WARN_SYMBOL"
    __message warning "${1}" "${2}"

    if [ -z "$2" ] || [ "$SHOW_OUTPUT" -eq 0 ]; then
        printf "\n"
    fi
}

__fail() {
    sek=$((sek-1))
    printf "\b%s\n" "$FAIL_SYMBOL"
    __message error "${1}" "${2}"

    if [ -z "$2" ] || [ "$SHOW_OUTPUT" -eq 0 ]; then
        printf "\n"
    fi
    HAS_ERRORS=1
}
