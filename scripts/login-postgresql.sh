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
# PostgreSQL Paths & Connection Defaults
# ==================================================
PG_BASE="/db1/myserver/postgresql"

PG_BIN="$PG_BASE/postgresql_files/percona-postgresql16/bin"
RUN_DIR="$PG_BASE/run"

PG_HOST="$RUN_DIR"
PG_PORT="5432"

# ==================================================
# User Input
# ==================================================
echo
read -rp "username: " PG_USER
echo

if [ -z "$PG_USER" ]; then
    log "No username provided. Aborting login."
    exit 1
fi

log "PostgreSQL interactive login requested"
log "Connecting with username: $PG_USER"
log "Host (socket directory): $PG_HOST"
log "Port: $PG_PORT"
log "Password will be requested by PostgreSQL if required"

# ==================================================
# Login Execution
# ==================================================
exec "$PG_BIN/psql" \
    -h "$PG_HOST" \
    -p "$PG_PORT" \
    -U "$PG_USER"
