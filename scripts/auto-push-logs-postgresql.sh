#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
CRONLOG_DIR="/db1/myserver/postgresql/cronlog"
LOG_DATE="$(date +%F)"
CRONLOG_FILE="$CRONLOG_DIR/postgresql-cronlog-$LOG_DATE.log"

mkdir -p "$CRONLOG_DIR"

log() {
  {
    echo "--------------------------------------------------"
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] [$SCRIPT_NAME]"
    echo "$@"
  } | tee -a "$CRONLOG_FILE"
}

REPO_DIR="/db1/github/postgresql"
TODAY=$(date +%F)

log "Starting PostgreSQL log push to main branch"

cd "$REPO_DIR"

log "Fetching latest changes from origin"
git fetch origin

log "Rebasing onto origin/main"
git rebase origin/main

log "Force adding archived PostgreSQL logs"
git add -f logs/*.log 2>/dev/null || true

if git diff --cached --quiet; then
  log "No new PostgreSQL logs to commit."
  exit 0
fi

log "Committing new PostgreSQL log files"
git commit -m "PostgreSQL log upload: $TODAY"

log "Pushing to origin/main"
git push origin main

log "PostgreSQL log push completed successfully"
