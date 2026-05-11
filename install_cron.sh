#!/usr/bin/env bash
# Reads SEND_TIME from .env and installs the cron job.
# Re-run this whenever you change SEND_TIME.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: .env not found. Run setup.sh first."
    exit 1
fi

SEND_TIME=$(grep -E '^SEND_TIME=' "$ENV_FILE" | cut -d '=' -f2 | tr -d '[:space:]')

if [[ -z "$SEND_TIME" ]]; then
    echo "Error: SEND_TIME is not set in .env"
    exit 1
fi

HOUR=$(echo "$SEND_TIME" | cut -d ':' -f1)
MINUTE=$(echo "$SEND_TIME" | cut -d ':' -f2)

if ! [[ "$HOUR" =~ ^[0-9]+$ ]] || ! [[ "$MINUTE" =~ ^[0-9]+$ ]] \
   || (( HOUR < 0 || HOUR > 23 )) || (( MINUTE < 0 || MINUTE > 59 )); then
    echo "Error: SEND_TIME must be HH:MM in 24-hour format (e.g. 19:00)"
    exit 1
fi

PYTHON="$SCRIPT_DIR/.venv/bin/python"
SCRIPT="$SCRIPT_DIR/gmail_summarizer.py"
LOG="$SCRIPT_DIR/summaries/cron.log"
CRON_LINE="$MINUTE $HOUR * * * $PYTHON $SCRIPT >> $LOG 2>&1"
MARKER="gmail_summarizer.py"

# Remove any existing entry for this script, then append the new one
(crontab -l 2>/dev/null | grep -v "$MARKER"; echo "$CRON_LINE") | crontab -

echo "Cron job installed: daily at ${SEND_TIME}"
echo "Entry: $CRON_LINE"
