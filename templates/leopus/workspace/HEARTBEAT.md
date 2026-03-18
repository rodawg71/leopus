# HEARTBEAT.md — Rotating Check System

One check per heartbeat. Most overdue wins. Silent unless actionable.

## Cadences

| Check   | Every    | Time Window    |
|---------|----------|----------------|
| System  | 24 hours | 3 AM–6 AM only |
| Git     | 24 hours | Anytime        |

## Check Implementations

### System
- `journalctl --since "24 hours ago" -p err -q --no-pager | head -20`
- `systemctl --user list-timers --no-pager`
- Report ONLY if: failed services, cron errors, disk >90%

### Git
- `cd ~/.openclaw/workspace && git status --short`
- Report ONLY if: uncommitted changes exist

## Rules
- One check per heartbeat — most overdue wins
- Silent unless actionable — no "all clear" messages
- Return `HEARTBEAT_OK` if nothing needs attention
