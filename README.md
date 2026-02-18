# PostgreSQL Database Server – Manual Linux Setup

This project documents a manually configured PostgreSQL 16 server running on Debian Linux with a structured automation and logging lifecycle.

The system is built as a learning-focused infrastructure project with production-style discipline and controlled automation.

---

## Overview

This server includes:

- Dedicated PostgreSQL instance (port 5432)
- Custom socket directory
- Manual service control scripts (start / stop / status / login)
- Internal PostgreSQL log rotation (date-based)
- Automated archival of daily logs
- Log sanitization before public upload
- Retention-based log cleanup
- Controlled GitHub archival of logs
- Cron-based execution pipeline

Logs from other internal projects may also be stored and version-controlled here for structured archival.

---

## Logging Architecture

PostgreSQL logging is configured with:

- `logging_collector = on`
- `log_filename = postgresql-%Y-%m-%d.log`
- Dedicated log directory:  
  `/db1/myserver/postgresql/logs`

Daily rotation is handled internally by PostgreSQL.

External scripts handle:

- Archival of yesterday’s completed log
- Sanitization of sensitive data
- Retention enforcement
- GitHub synchronization

This ensures the database engine controls file handling while automation handles lifecycle management.

---

## Daily Automation Flow

12:02 A.M – Archive yesterday’s PostgreSQL log  
12:03 A.M – Sanitize archived logs (mask IPs, ports, emails)  
12:04 A.M – Auto-push sanitized logs to GitHub  
12:05 A.M – Delete old logs (retention policy)

No manual log rotation or forced reload is required due to PostgreSQL’s internal date-based rotation.

---

## Design Principles

- PostgreSQL manages log rotation internally
- Clear separation between runtime server directory and Git-controlled directory
- Logs ignored by default via `.gitignore`
- Explicit forced-add for controlled log uploads
- Sanitization layer before public archival
- Retention policies applied to both server and GitHub logs
- No database binaries or data directory stored in Git
- Minimal moving parts, deterministic behavior

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
