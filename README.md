# PostgreSQL Database Server – Manual Linux Setup

This project documents a manually configured PostgreSQL 16 server running on Debian Linux with a structured automation and logging lifecycle.

The system is built as a learning-focused infrastructure project with production-style discipline, controlled automation, and clear separation between engine responsibility and operational scripting.

---

## Overview

This server includes:

- Dedicated PostgreSQL instance (port 5432)
- Custom socket directory
- Manual service control scripts (start / stop / status / login)
- Internal PostgreSQL log rotation (date-based, engine-managed)
- Automated archival of completed daily logs
- Log sanitization before public upload
- Retention-based log cleanup
- Controlled GitHub archival of logs
- Cron-based lifecycle orchestration

Logs from other internal projects may also be stored and version-controlled here for structured archival.

---

## Logging Architecture

PostgreSQL logging is configured with:

- `logging_collector = on`
- `log_filename = postgresql-%Y-%m-%d.log`
- `log_directory = /db1/myserver/postgresql/logs`

Daily rotation is handled entirely by PostgreSQL itself.

At midnight, PostgreSQL automatically creates:

postgresql-YYYY-MM-DD.log

No external rename or reload is required.

### Responsibility Separation

**PostgreSQL (Engine Layer):**
- Creates log files
- Manages file descriptors
- Controls ownership and permissions
- Handles safe daily rotation

**Automation Scripts (Lifecycle Layer):**
- Archive yesterday’s completed log
- Sanitize sensitive data
- Push sanitized logs to GitHub
- Enforce retention policies

This ensures the database engine controls file safety while automation manages lifecycle hygiene.

---

## Daily Automation Flow

All steps are executed via a single orchestrator script:

run-postgresql-lifecycle.sh

12:02 A.M – Archive Yesterday’s Log  
12:03 A.M – Sanitize Archived Logs  
12:04 A.M – Auto Push Logs to GitHub  
12:05 A.M – Retention Cleanup  

No manual log rotation or forced reload is required because PostgreSQL performs rotation internally.

---

## Design Principles

- Engine-managed log rotation (no manual rename logic)
- Deterministic nightly lifecycle
- Clear separation between runtime directory and Git repository
- Logs ignored by default via `.gitignore`
- Explicit forced-add for controlled log uploads
- Sanitization before public archival
- Retention policy enforcement
- No database binaries or data directory stored in Git
- Minimal moving parts, predictable behavior

---

## Directory Separation

### Runtime Server Directory

/db1/myserver/postgresql

Contains:
- data
- binaries
- socket files
- runtime logs
- execution scripts

This directory is not version-controlled.

### Git-Controlled Directory

/db1/github/postgresql

Contains:
- config
- scripts
- sanitized archived logs
- documentation

This directory is version-controlled and safe for remote push.

---

## Isolation Model

This PostgreSQL instance operates independently with:

- Dedicated port (5432)
- Dedicated socket directory
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- Manual pg_ctl-based process management (no systemd dependency)

This prevents cross-instance interference and ensures predictable behavior.

---

## Environment

- Debian Linux
- Manual PostgreSQL installation (no systemd dependency)
- Percona PostgreSQL 16 binaries
- Cron-based automation
- Development laptop → GitHub → Server laptop architecture

---

## Purpose

This repository serves as:

- A learning-focused infrastructure project
- A structured PostgreSQL server implementation
- A logging lifecycle automation reference
- A Git-integrated log archival model
- A foundation for future production-style hardening
- A controlled experiment in deterministic database operations
