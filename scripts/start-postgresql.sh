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
# PostgreSQL Paths & Configuration
# ==================================================
PG_BASE="/db1/myserver/postgresql"

PG_BIN="$PG_BASE/postgresql_files/percona-postgresql16/bin"
PGDATA="$PG_BASE/data"
PGCONF="$PG_BASE/config/postgresql.conf"
LOG_DIR="$PG_BASE/logs"
RUN_DIR="$PG_BASE/run"
BOOTSTRAP_LOG="$LOG_DIR/server-bootstrap.log"

mkdir -p "$LOG_DIR" "$RUN_DIR"
chmod 700 "$RUN_DIR"

# ==================================================
# Start Logic
# ==================================================
log "Start request received for PostgreSQL"

if "$PG_BIN/pg_ctl" -D "$PGDATA" status >/dev/null 2>&1; then
    log "PostgreSQL is already running"
    exit 0
fi

log "PostgreSQL is not running"
log "Starting PostgreSQL server"

"$PG_BIN/pg_ctl" \
    -D "$PGDATA" \
    -l "$BOOTSTRAP_LOG" \
    -o "-c config_file=$PGCONF" \
    start

log "PostgreSQL start command issued"
log "Bootstrap log location: $BOOTSTRAP_LOG"
