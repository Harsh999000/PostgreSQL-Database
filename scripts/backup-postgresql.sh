#!/bin/bash
set -euo pipefail

# ==================================================
# Script Identity & Cron Logging Setup
# ==================================================
SCRIPT_NAME="$(basename "$0")"

CRONLOG_DIR="/db1/myserver/postgresql/cronlog"
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
# PostgreSQL Paths & Backup Configuration
# ==================================================
PG_BASE="/db1/myserver/postgresql"

PG_BIN="$PG_BASE/postgresql_files/percona-postgresql16/bin"
BACKUP_DIR="$PG_BASE/backup"

PG_USER="postgres"

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP_FILE="$BACKUP_DIR/postgresql-backup-${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

# ==================================================
# Backup Logic
# ==================================================
log "PostgreSQL backup requested"
log "Backup directory: $BACKUP_DIR"
log "Backup file: $BACKUP_FILE"
log "Backup method: pg_dumpall (full cluster backup)"

log "Starting PostgreSQL backup now"

"$PG_BIN/pg_dumpall" \
    -U "$PG_USER" \
    > "$BACKUP_FILE"

log "PostgreSQL backup completed successfully"
log "Backup size: $(du -h "$BACKUP_FILE" | awk '{print $1}')"
