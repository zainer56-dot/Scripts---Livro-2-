#!/bin/bash
SCRIPT_NAME=$(basename "$0")
OUTPUT_FILE=$(mktemp /tmp/hgrep.XXXXXX)

function usage {
    echo -e "\nUSAGE: $SCRIPT_NAME pattern [filename]\n"
}

# --- Check arguments ---
if (( $# == 1 )); then
    PATTERN="$1"
    FILENAME=""
elif (( $# == 2 )); then
    PATTERN="$1"
    FILENAME="$2"

    if [ ! -f "$FILENAME" ]; then
        echo -e "\nERROR: $FILENAME does not exist"
        usage
        exit 2
    fi
    if [ ! -s "$FILENAME" ]; then
        printf "\nERROR: %s file size is zero...nothing to search\n" "$FILENAME"
        usage
        exit 2
    fi
    if [ ! -r "$FILENAME" ]; then
        printf "\nERROR: %s is not readable\n" "$FILENAME"
        usage
        exit 2
    fi
    grep -Fq "$PATTERN" "$FILENAME" || { 
        printf "\nSORRY: Pattern '%s' not found in %s\n" "$PATTERN" "$FILENAME"
        exit 3
    }
else
    usage
    exit 1
fi

# --- Highlight ---
if [[ -n "$FILENAME" ]]; then
    sed "s|${PATTERN}|$(tput smso)${PATTERN}$(tput sgr0)|g" "$FILENAME" | more
else
    sed "s|${PATTERN}|$(tput smso)${PATTERN}$(tput sgr0)|g" > "$OUTPUT_FILE"
    grep -Fq "$PATTERN" "$OUTPUT_FILE" || {
        printf "\nERROR: Pattern '%s' not found in stdin\n" "$PATTERN"
        exit 3
    }
    more "$OUTPUT_FILE"
fi

# Cleanup
rm -f "$OUTPUT_FILE"
