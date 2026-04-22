# LLAMY_TRIGGER_WIKI.md

A searchable reference for Llamy’s built-in trigger phrases.

Use this file when you want to remember:
- which phrases already exist
- what each phrase is supposed to do
- whether a phrase returns status, runs an export, or sends screenshots

## Quick index

- `usage status` → OpenClaw usage summary
- `session status` → current model/session status
- `openclaw health` → gateway/system health summary
- `llamy room status` → `#llama` room/session health
- `Pine screener` → latest cached Pine screener table
- `refresh pine screener` → fresh Pine screener export
- `pine screener with winner screenshot` → latest valid winner package + winner screenshots (4H and 1D)
- `refresh pine screener with winner screenshot` → force a fresh screener run + winner screenshots
- `show winner screenshots` → latest stored winner screenshots only
- `trigger llama screener` → queue a fresh one-shot run from `#llama` and deliver output to `#llama-screener`

---

## 1) OpenClaw usage

**Primary trigger**
- `usage status`

**Also recognized**
- `openclaw usage`
- `show usage`
- `Run exactly: openclaw status --usage`

**What it does**
- Returns the current OpenClaw usage status.

**Reply style**
- Script output only.

---

## 2) Current session/model status

**Primary trigger**
- `session status`

**Also recognized**
- `show current model status`
- `what model are you using right now?`

**What it does**
- Returns the current session/model status for Llamy.

**Reply style**
- Short model/context summary.

---

## 3) OpenClaw / gateway health

**Primary trigger**
- `openclaw health`

**Also recognized**
- `gateway health`
- `system health`

**What it does**
- Returns a compact OpenClaw / gateway health summary.

**Reply style**
- Script output only.

---

## 4) Llamy room status

**Primary trigger**
- `llamy room status`

**Also recognized**
- `check llama room`
- `check #llama`
- `is #llama alive?`

**What it does**
- Returns a concise status of the `#llama` room session.

**Reply style**
- Script output only.

---

## 5) Pine screener status (cached)

**Primary trigger**
- `Pine screener`

**Also recognized**
- `screener`
- `run the screener`

**What it does**
- Returns the latest cached/local Pine screener table.
- Does **not** rerun TradingView.

**Freshness rule**
- If the latest local report is older than 1 hour, Llamy should reply:
  - `Pine screener stale. Run refresh pine screener.`

**Reply style**
- Table only.
- No intro text.

---

## 6) Pine screener refresh/export

**Primary trigger**
- `refresh pine screener`

**Also recognized**
- `rerun pine screener`
- `run pine screener export`
- `export pine screener`
- `update pine screener`

**What it does**
- Reruns the local TradingView Pine screener export pipeline.
- Produces a fresh screener table.

**Reply style**
- Fresh table only.
- No intro text.

**Failure line**
- `Pine screener export failed.`

---

## 7) Pine screener with winner screenshot

**Primary trigger**
- `pine screener with winner screenshot`

**Also recognized**
- `refresh pine screener with winner screenshot`
- `winner screenshot`
- `run pine screener with winner screenshot`

**What it does**
- Uses the latest good local winner package if one already exists.
- The cached package is only considered valid when it is tagged with the `Openclaw-structure` layout.
- Detects the stored top winner.
- Provides winner screenshots for:
  - 4H
  - 1D
- Uses the TradingView `Openclaw-structure` chart layout (`0ZPSKaZ4`) for both screenshots.
- Returns the screener table plus media paths for those screenshots.
- Use the explicit refresh variant when you want a forced new rerun.

**Reply style**
- Table first.
- Then two `MEDIA:./...` lines.
- No `Winner:` or `Attached:` prose.

**Failure line**
- `Pine screener winner screenshot failed.`

---

## 8) Winner screenshots only

**Primary trigger**
- `show winner screenshots`

**Also recognized**
- `winner screenshots only`
- `attach winner screenshots`
- `show the winner screenshots`

**What it does**
- Returns only the latest stored winner screenshots from the most recent successful screener-with-screenshots run.
- Does **not** rerun the screener.

**Reply style**
- Minimal winner line.
- Then two `MEDIA:./...` lines.

**Failure line**
- `Winner screenshots unavailable.`

---

## 9) Manual llama screener dispatch

**Primary trigger**
- `trigger llama screener`

**Also recognized**
- `run llama screener now`
- `send llama screener`
- `refresh llama screener now`

**What it does**
- Runs a fresh screener dispatch from the `#llama` room.
- Pings the configured Qwen backend first so it can fail fast if that PC is asleep/off.
- Builds the final delivery body locally.
- Forwards the result to `#llama-screener`.
- Avoids relying on the flaky manual cron path.

**Reply style**
- Current room gets a short acknowledgement only.
- The screener table + screenshots land in `#llama-screener`.

**Acknowledgement**
- `Sent to #llama-screener.`

**Fast-fail line**
- `Qwen host offline. Not sent.`

---

## 10) Winner screenshots only

**Primary trigger**
- `show winner screenshots`

**Also recognized**
- `winner screenshots only`
- `attach winner screenshots`
- `show the winner screenshots`

**What it does**
- Returns only the latest stored winner screenshots from the most recent successful screener-with-screenshots run.
- Does **not** rerun the screener.

**Reply style**
- Minimal winner line.
- Then two `MEDIA:./...` lines.

**Failure line**
- `Winner screenshots unavailable.`

---

## Notes

- `TASKBOOK.md` remains the operational source of truth for execution behavior.
- This file is the human-facing wiki/index for quickly searching available trigger phrases.
- When new trigger tasks are added, update both:
  - `TASKBOOK.md`
  - `docs/LLAMY_TRIGGER_WIKI.md`
