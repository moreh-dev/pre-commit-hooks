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

for PROJECT_KEY in $PROJECT_KEYS; do
    ISSUE_KEY=$(echo "$BRANCH_NAME" | grep -oE "^$PROJECT_KEY-[0-9]+" || echo "")
    if [ -n "$ISSUE_KEY" ]; then
        break
    fi
done

if [ -z "$ISSUE_KEY" ]; then
    if [ "$ENABLE_NO_ISSUE" = true ]; then
        ISSUE_KEY="NO-ISSUE"
    else
        exit 0
    fi
fi

TMP_MSG=$(cat "$COMMIT_MSG_FILE")

case "$TMP_MSG" in
$ISSUE_KEY*)
    exit 0
    ;;
esac

echo "$ISSUE_KEY: $TMP_MSG" >"$COMMIT_MSG_FILE"
