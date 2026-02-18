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
# PostgreSQL Paths
# ==================================================
PG_BASE="/db1/myserver/postgresql"

PG_BIN="$PG_BASE/postgresql_files/percona-postgresql16/bin"
PGDATA="$PG_BASE/data"

# ==================================================
# Stop Logic
# ==================================================
log "Stop request received for PostgreSQL"

if ! "$PG_BIN/pg_ctl" -D "$PGDATA" status >/dev/null 2>&1; then
    log "PostgreSQL is already stopped"
    exit 0
fi

log "PostgreSQL is currently running"
log "Initiating fast shutdown"

"$PG_BIN/pg_ctl" -D "$PGDATA" stop -m fast

log "PostgreSQL stop command completed"
