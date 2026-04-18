# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Llamy helper scripts

- `scripts/get_openclaw_usage.ps1` — returns only the `Usage` block from `openclaw status --usage`
- `scripts/get_openclaw_health.ps1` — compact OpenClaw health summary from `openclaw status --json`
- `scripts/get_llama_room_status.ps1` — concise status for the `#llama` Discord room session
- `scripts/get_pine_screener_status.ps1` — prints only the latest local Pine screener text table, or `Pine screener unavailable.`
- `TASKBOOK.md` — known task playbook; read this when a request matches a repeatable task

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
