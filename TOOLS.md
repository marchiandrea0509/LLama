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
- `scripts/run_pine_screener_export.ps1` — reruns `workspace\\tradingview\\scripts\\pine_screener_export.js` and returns only the fresh text table, or `Pine screener export failed.`
- `scripts/run_pine_screener_with_winner_shots.ps1` — reruns the screener, selects the top winner, captures 4H + 1D screenshots on the TradingView `Openclaw-structure` chart, and writes layout-specific files plus a manifest under `artifacts\\pine_screener_winner\\`
- `scripts/get_pine_screener_with_winner_shots_status.ps1` — returns the latest good local winner table immediately if artifacts exist; the explicit refresh phrase is what forces a new rerun
- `scripts/get_latest_winner_screenshots.ps1` — returns the latest winner name plus 4H/1D screenshot paths from the manifest, or `Winner screenshots unavailable.`
- `scripts/get_latest_winner_media_refs.ps1` — returns the winner plus safe `MEDIA:./artifacts/...` lines for direct room/manual usage
- `scripts/get_llama_screener_cron_delivery.ps1` — Qwen-friendly one-shot wrapper for the llama screener cron; emits the final delivery body directly and mirrors screenshots into the canonical `C:\Users\anmar\.openclaw\workspace\artifacts\llama_screener_winner\` path so OpenClaw can attach them
- `workspace\\tradingview\\scripts\\pine_screener_export.js` — full TradingView Pine Screener export pipeline (CSV/JSON/PNG/MD/TXT artifacts)
- `workspace\\tradingview\\scripts\\capture_live.js` — captures a live TradingView chart screenshot for a chosen symbol/timeframe
- `TASKBOOK.md` — known task playbook; read this when a request matches a repeatable task
- `docs/LLAMY_TRIGGER_WIKI.md` — human-facing searchable wiki of Llamy trigger phrases and what they do

## Pine screener artifact hygiene

- Keep the active winner package at `artifacts\\pine_screener_winner\\` top level:
  - `latest_manifest.json`
  - `latest_table.txt`
  - current `*_Openclaw-structure.png` files and matching `_meta.json`
  - `capture.log` when it is still useful for the latest capture run
- Move stale test logs and pre-layout / superseded screenshots into `artifacts\\pine_screener_winner\\archive\\YYYY-MM-DD_cleanup\\` instead of leaving them beside the live package.
- Prefer preserving the files referenced by `latest_manifest.json`; do not archive or delete those unless replacing the manifest in the same change.
- For cron delivery, do not send screenshots directly from `workspace-llama`; OpenClaw's default local-media allowlist accepts the canonical `C:\Users\anmar\.openclaw\workspace\...` tree and can reject sibling roots like `workspace-llama`.

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
