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
# Log Directory Configuration
# ==================================================
LOG_DIR="/db1/github/postgresql/logs"

# ==================================================
# Sanitization Start
# ==================================================
log "PostgreSQL log sanitization started"
log "Target log directory: $LOG_DIR"

if [ ! -d "$LOG_DIR" ]; then
    log "PostgreSQL GitHub log directory not found"
    log "Sanitization aborted"
    exit 0
fi

LOG_COUNT=$(find "$LOG_DIR" -type f -name "postgresql-*.log" | wc -l)

log "Total PostgreSQL archived logs found: $LOG_COUNT"

if [ "$LOG_COUNT" -eq 0 ]; then
    log "No archived logs to sanitize"
    log "Sanitization completed with no changes"
    exit 0
fi

# ==================================================
# Sanitization Logic
# ==================================================
find "$LOG_DIR" -type f -name "postgresql-*.log" | while read -r file; do

    log "Sanitizing file: $file"

    # Skip file if already sanitized (optional lightweight check)
    if grep -q "xxx.xxx.xxx.xxx" "$file"; then
        log "File appears already sanitized, skipping: $file"
        continue
    fi

    sed -i -E '
        # Mask IPv4
        s/\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/xxx.xxx.xxx.xxx/g;

        # Mask IPv6 (basic match)
        s/\b([0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{1,4}\b/xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx/g;

        # Mask host:port patterns (e.g. 192.168.1.10:5432 or localhost:5432)
        s/([A-Za-z0-9._-]+):[0-9]{2,5}/\1:PORT/g;

        # Mask email addresses
        s/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,10}\b/xxx@xxx/g;
    ' "$file"

    log "Sanitization completed for file: $file"
done

# ==================================================
# Sanitization Complete
# ==================================================
log "PostgreSQL log sanitization completed successfully"
