#!/bin/bash
set -euo pipefail

# ==================================================
# PostgreSQL Nightly Lifecycle Orchestrator
# Executes all maintenance steps sequentially.
# If any step fails, execution stops immediately.
# ==================================================

SCRIPT_NAME="$(basename "$0")"
CRONLOG_DIR="/db1/myserver/postgresql/cronlogs"
LOG_DATE="$(date +%F)"
CRONLOG_FILE="$CRONLOG_DIR/postgresql-cronlog-$LOG_DATE.log"

mkdir -p "$CRONLOG_DIR"

log() {
  {
    echo "=================================================="
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] [$SCRIPT_NAME]"
    echo "$@"
  } | tee -a "$CRONLOG_FILE"
}

BASE="/db1/myserver/postgresql/scripts"

log "Starting PostgreSQL full lifecycle"

# --------------------------------------------------
# Archive Yesterday's Log
# Copies completed daily log to GitHub directory.
# --------------------------------------------------
"$BASE/rotate-logs-postgresql.sh" &&
log "Log archival completed"

# --------------------------------------------------
# Sanitize Archived Logs
# Masks sensitive information before version control.
# --------------------------------------------------
"$BASE/sanitize-logs-postgresql.sh" &&
log "Log sanitization completed"

# --------------------------------------------------
# Auto Push Logs
# Force-adds archived logs and pushes to GitHub.
# --------------------------------------------------
"$BASE/auto-push-logs-postgresql.sh" &&
log "Log push completed"

# --------------------------------------------------
# Delete Old Logs
# Applies retention policy to server and GitHub logs.
# --------------------------------------------------
"$BASE/delete-logs-postgresql.sh" &&
log "Log cleanup completed"

log "PostgreSQL lifecycle completed successfully"
