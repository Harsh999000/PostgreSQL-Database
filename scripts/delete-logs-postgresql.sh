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
# Log Directories & Retention Policies
# ==================================================

GITHUB_LOG_DIR="/db1/github/postgresql/logs"
GITHUB_RETENTION_DAYS=7

MAIN_LOG_DIR="/db1/myserver/postgresql/logs"
MAIN_RETENTION_DAYS=14

CRONLOG_RETENTION_DAYS=14

# ==================================================
# Cleanup Start
# ==================================================
log "PostgreSQL log cleanup started"
log "GitHub retention: ${GITHUB_RETENTION_DAYS} days"
log "Main log retention: ${MAIN_RETENTION_DAYS} days"
log "Cron log retention: ${CRONLOG_RETENTION_DAYS} days"

# ==================================================
# Cleanup GitHub Archived Logs
# ==================================================
if [ -d "$GITHUB_LOG_DIR" ]; then
    OLD_FILES=$(find "$GITHUB_LOG_DIR" -type f -name "postgresql-*.log" -mtime +$GITHUB_RETENTION_DAYS)

    if [ -n "$OLD_FILES" ]; then
        COUNT=$(echo "$OLD_FILES" | wc -l)
        log "Deleting $COUNT GitHub archived log(s) older than ${GITHUB_RETENTION_DAYS} days"
        echo "$OLD_FILES" | xargs -r rm -f
    else
        log "No GitHub archived logs older than ${GITHUB_RETENTION_DAYS} days"
    fi
else
    log "GitHub PostgreSQL log directory not found"
fi

# ==================================================
# Cleanup Main PostgreSQL Logs
# ==================================================
if [ -d "$MAIN_LOG_DIR" ]; then
    OLD_FILES=$(find "$MAIN_LOG_DIR" -type f -name "postgresql-*.log" -mtime +$MAIN_RETENTION_DAYS)

    if [ -n "$OLD_FILES" ]; then
        COUNT=$(echo "$OLD_FILES" | wc -l)
        log "Deleting $COUNT PostgreSQL server log(s) older than ${MAIN_RETENTION_DAYS} days"
        echo "$OLD_FILES" | xargs -r rm -f
    else
        log "No PostgreSQL server logs older than ${MAIN_RETENTION_DAYS} days"
    fi
else
    log "PostgreSQL server log directory not found"
fi

# ==================================================
# Cleanup PostgreSQL Cron Logs
# ==================================================
if [ -d "$CRONLOG_DIR" ]; then
    OLD_FILES=$(find "$CRONLOG_DIR" -type f -name "postgresql-cronlog-*.log" -mtime +$CRONLOG_RETENTION_DAYS)

    if [ -n "$OLD_FILES" ]; then
        COUNT=$(echo "$OLD_FILES" | wc -l)
        log "Deleting $COUNT PostgreSQL cron log(s) older than ${CRONLOG_RETENTION_DAYS} days"
        echo "$OLD_FILES" | xargs -r rm -f
    else
        log "No PostgreSQL cron logs older than ${CRONLOG_RETENTION_DAYS} days"
    fi
else
    log "PostgreSQL cron log directory not found"
fi

# ==================================================
# Cleanup Complete
# ==================================================
log "PostgreSQL log cleanup completed"
