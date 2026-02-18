# PostgreSQL Server Architecture

This document describes the automated operational lifecycle of the PostgreSQL server instance running on the server laptop.

The system is designed for deterministic daily execution, internal engine-managed log rotation, and clean separation of responsibilities between the database engine and automation scripts.

---

## Daily Automation Schedule

All operations are executed sequentially starting at 12:02 A.M.

PostgreSQL handles daily log rotation internally using date-based filenames.  
Automation scripts manage archival, sanitization, retention, and Git synchronization.

---

### 12:02 A.M – Archive Yesterday’s Log  
**Script:** `rotate-logs-postgresql.sh`  
*(Archival script — no manual rotation performed)*

**Purpose:**

- Identifies yesterday’s completed log file:

postgresql-YYYY-MM-DD.log

- Copies it to:

/db1/github/postgresql/logs

- Does NOT rename files.
- Does NOT create new log files.
- Does NOT reload PostgreSQL.

PostgreSQL already performs daily log rotation internally using:


logging_collector = on
log_filename = postgresql-%Y-%m-%d.log


This step simply archives the completed daily log.

---

### 12:03 A.M – Sanitize Logs  
**Script:** `sanitize-logs-postgresql.sh`

**Purpose:**

- Masks sensitive information in archived logs:
  - IPv4 addresses
  - IPv6 addresses
  - Host:port combinations
  - Email addresses
- Operates only on GitHub archived logs.
- Does not modify live server logs.

This ensures logs are safe for version control and external archival.

---

### 12:04 A.M – Auto Push Logs to GitHub  
**Script:** `auto-push-logs-postgresql.sh`

**Purpose:**

- Force-adds archived log files (ignored by default via `.gitignore`)
- Commits only if changes exist
- Pushes updates to remote GitHub repository

Important:

- Manual `git add .` does NOT include logs
- Logs are intentionally added via automation
- GitHub functions as controlled archival storage

---

### 12:05 A.M – Delete Logs (Retention Policy)  
**Script:** `delete-logs-postgresql.sh`

**Retention Rules:**

**GitHub archived logs directory:**
- Delete logs older than 7 days (local repository copy only)

**Internal PostgreSQL logs directory:**
- Delete logs older than 14 days

**Cron execution logs:**
- Delete logs older than 14 days

Active daily log file is never deleted because its modification time remains current.

This enforces controlled storage usage while preserving short-term audit history.

---

## Logging Architecture

PostgreSQL manages rotation internally using:

logging_collector = on
log_directory = /db1/myserver/postgresql/logs
log_filename = postgresql-%Y-%m-%d.log


This ensures:

- Automatic daily log separation
- Safe file descriptor management
- No manual reload required for rotation
- Deterministic date-based filenames

Automation scripts operate only on completed log files.

---

## Isolation Principles

This PostgreSQL instance is fully isolated by:

- Dedicated port (5432)
- Dedicated socket directory
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- Manual `pg_ctl`-based process control (no systemd dependency)

This prevents cross-service interference and maintains clean process boundaries.

---

## Directory Separation

### Runtime Server Directory

/db1/myserver/postgresql

Contains:
- data
- binaries
- socket
- runtime logs
- execution scripts

Not version-controlled.

---

### Git-Controlled Directory

/db1/github/postgresql

Contains:
- config
- scripts
- sanitized archived logs
- documentation

Version-controlled and safe for remote push.

---

## Design Philosophy

- PostgreSQL handles log rotation internally
- Automation handles archival and hygiene
- Deterministic execution order
- Strict separation between runtime and repository
- Retention policy enforcement
- Append-only archival behavior in GitHub
- Safe automation via cron scheduling
- Minimal moving parts, maximum predictability

---

## Operational Model Summary

PostgreSQL rotates logs daily →  
Automation archives yesterday’s file →  
Logs are sanitized →  
Logs are pushed to GitHub →  
Old logs are removed according to retention policy.

This creates a structured, layered logging lifecycle with clear responsibility boundaries between the database engine and automation layer.

