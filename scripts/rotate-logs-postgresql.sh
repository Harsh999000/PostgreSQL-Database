#!/bin/bash
set -euo pipefail

# ==================================================
# Script Identity & Cron Logging Setup
# ==================================================
SCRIPT_NAME="$(basename "$0")"

CRONLOG_DIR="/db1/myserver/postgresql/cronlogs"
LOG_DATE="$(date +%F)"
CRONLOG_FILE="$CRONLOG_DIR/postgresql-cronlog-${LOG_DATE}.log"

mkdir -p "$CRONLOG_DIR"

log() {
    {
        echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] [$SCRIPT_NAME]"
        echo "$@"
        echo "----------------------------------------"
    } | tee -a "$CRONLOG_FILE"
}

# ==================================================
# Directory Configuration
# ==================================================
MAIN_LOG_DIR="/db1/myserver/postgresql/logs"
GITHUB_LOG_DIR="/db1/github/postgresql/logs"

YESTERDAY="$(date -d 'yesterday' +%F)"
YESTERDAY_LOG="postgresql-${YESTERDAY}.log"
SOURCE_FILE="$MAIN_LOG_DIR/$YESTERDAY_LOG"
DEST_FILE="$GITHUB_LOG_DIR/$YESTERDAY_LOG"

mkdir -p "$GITHUB_LOG_DIR"

# ==================================================
# Archive Start
# ==================================================
log "PostgreSQL log archival started"
log "Looking for yesterday's log: $YESTERDAY_LOG"

if [ ! -d "$MAIN_LOG_DIR" ]; then
    log "Main PostgreSQL log directory not found"
    log "Expected path: $MAIN_LOG_DIR"
    log "Archival aborted"
    exit 1
fi

# ==================================================
# Check if Yesterday's Log Exists
# ==================================================
if [ ! -f "$SOURCE_FILE" ]; then
    log "Yesterday's log file not found: $SOURCE_FILE"
    log "Nothing to archive"
    exit 0
fi

# ==================================================
# Copy to GitHub Directory
# ==================================================
log "Copying $YESTERDAY_LOG to GitHub archive directory"

cp "$SOURCE_FILE" "$DEST_FILE"

log "Successfully archived $YESTERDAY_LOG"
log "PostgreSQL log archival completed"
