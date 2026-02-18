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
# Repository Configuration
# ==================================================
REPO_DIR="/db1/github/postgresql"
LOG_DIR="$REPO_DIR/logs"
TODAY="$(date +%F)"

log "PostgreSQL auto-push process started"
log "Repository directory: $REPO_DIR"
log "Log directory: $LOG_DIR"

if [ ! -d "$REPO_DIR/.git" ]; then
    log "Not a valid Git repository: $REPO_DIR"
    log "Auto-push aborted"
    exit 1
fi

cd "$REPO_DIR"

# ==================================================
# Add Sanitized Log Files
# ==================================================
log "Staging sanitized PostgreSQL logs"

git add -f logs/postgresql-*.log 2>/dev/null || true

# ==================================================
# Check for Staged Changes
# ==================================================
if git diff --cached --quiet; then
    log "No new PostgreSQL logs to commit"
    log "Auto-push completed with no changes"
    exit 0
fi

# ==================================================
# Commit and Push
# ==================================================
log "Committing PostgreSQL logs"

git commit -m "PostgreSQL log upload: $TODAY"

log "Pushing to origin main"

git push origin main

log "PostgreSQL auto-push completed successfully"
