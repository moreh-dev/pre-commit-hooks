#!/usr/bin/env sh

set -e

if ! getopt -T >/dev/null; then
    options=$(getopt \
        -o k:n \
        -l key:,enable-no-issue \
        -n "$(basename "$0")" \
        -- "$@")
else
    eval set -- "$(echo "$@" | sed 's/--key/-k/g')"
    eval set -- "$(echo "$@" | sed 's/--enable-no-issue/-n/g')"
    options=$(getopt k:n "$@")
fi

eval set -- "$options"

while true; do
    case "$1" in
    -k | --key)
        if [ -z "$PROJECT_KEYS" ]; then
            PROJECT_KEYS="$2"
        else
            PROJECT_KEYS="$PROJECT_KEYS $2"
        fi
        shift 2
        ;;
    -n | --enable-no-issue)
        ENABLE_NO_ISSUE=true
        shift
        ;;
    --)
        COMMIT_MSG_FILE=$2
        shift 2
        break
        ;;
    *)
        shift
        ;;
    esac
done

BRANCH_NAME=$(git symbolic-ref --short HEAD 2>/dev/null || echo "unknown")
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

for PROJECT_KEY in $PROJECT_KEYS; do
    ISSUE_KEY=$(echo "$BRANCH_NAME" | grep -oE "^$PROJECT_KEY-[0-9]+" || echo "")

    if [ -n "$ISSUE_KEY" ]; then
        break
    fi
done

# Prepare regex for expected keys (Project Keys + NO-ISSUE)
PROJECT_KEYS_REGEX=$(echo "$PROJECT_KEYS" | sed 's/ /|/g')

if [ -z "$ISSUE_KEY" ]; then
    if [ "$ENABLE_NO_ISSUE" = true ]; then
        ISSUE_KEY="NO-ISSUE"
    else
        exit 0
    fi
fi

# Remove existing key from the first line of the message to prevent duplication
# We apply the substitution only to the first line (1s)
CLEAN_MSG=$(echo "$COMMIT_MSG" | sed -E "1s/^(NO-ISSUE|($PROJECT_KEYS_REGEX)-[0-9]+): //")

echo "$ISSUE_KEY: $CLEAN_MSG" >"$COMMIT_MSG_FILE"
