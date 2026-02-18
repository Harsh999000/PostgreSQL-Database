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
# PostgreSQL Paths
# ==================================================
PG_BASE="/db1/myserver/postgresql"
PG_BIN="$PG_BASE/postgresql_files/percona-postgresql16/bin"
PGDATA="$PG_BASE/data"

# ==================================================
# Flush Start
# ==================================================
log "PostgreSQL log flush requested"

# --------------------------------------------------
# Check PostgreSQL status
# --------------------------------------------------
if ! "$PG_BIN/pg_ctl" -D "$PGDATA" status >/dev/null 2>&1; then
    log "PostgreSQL is not running"
    log "Log flush cannot be performed"
    exit 1
fi

log "PostgreSQL is running"
log "Issuing log reload to force log file reopen"

# --------------------------------------------------
# Flush Logs (Reload)
# --------------------------------------------------
"$PG_BIN/pg_ctl" -D "$PGDATA" reload

log "PostgreSQL configuration reloaded"
log "PostgreSQL log flush completed"
log "PostgreSQL should now be writing to new log files"
