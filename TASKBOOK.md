# TASKBOOK.md - Known Tasks for Llamy

Use this file for repeatable tasks that should be handled the same way every time.

## Rules

- Prefer the known task recipe over improvising.
- For exact command tasks, use `exec` directly.
- For fragile status lookups, prefer a wrapper script if one exists.
- If the task says "reply with exactly X", the final reply must be exactly `X`.
- If a known task fails, say briefly that it failed instead of explaining tools in the abstract.

## Known tasks

### 1) Usage status

**Trigger examples**
- `usage status`
- `openclaw usage`
- `show usage`
- `Run exactly: openclaw status --usage`

**Action**
- Use `exec` to run:
  - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_openclaw_usage.ps1`

**Reply format**
- Return only the script output.
- Do not add intro text.
- Do not explain tools.

**Fallback**
- `I couldn't retrieve usage right now.`

### 2) Exact reply test

**Trigger examples**
- `Reply with exactly LLAMY OK`
- `Reply with exactly <text>`

**Action**
- Do not call cross-session tools.
- Send a normal assistant reply in the current chat.

**Reply format**
- Final reply must be exactly the requested text.

### 3) Current session/model status

**Trigger examples**
- `session status`
- `show current model status`
- `what model are you using right now?`

**Action**
- Use `session_status` for the current session.

**Reply format**
- Keep it short.
- Include model and context/use summary.

**Fallback**
- `I couldn't retrieve current session status right now.`

### 4) OpenClaw health

**Trigger examples**
- `openclaw health`
- `gateway health`
- `system health`

**Action**
- Use `exec` to run:
  - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_openclaw_health.ps1`

**Reply format**
- Return only the script output.
- Do not add intro text.

**Fallback**
- `I couldn't retrieve OpenClaw health right now.`

### 5) Llamy room status

**Trigger examples**
- `llamy room status`
- `check llama room`
- `check #llama`
- `is #llama alive?`

**Action**
- Use `exec` to run:
  - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_llama_room_status.ps1`

**Reply format**
- Return only the script output.
- Do not add intro text.

**Fallback**
- `I couldn't retrieve the llama room status right now.`

### 6) Pine screener status

**Trigger examples**
- `Pine screener`
- `screener`
- `run the screener`

**Action**
- Use `exec` to run:
  - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_pine_screener_status.ps1`

**Reply format**
- Return only the script output.
- Do not add intro text.
- Do not summarize the table.

**Fallback**
- `Pine screener unavailable.`

## Template for future tasks

### Task name

**Trigger examples**
- `...`

**Action**
- Use `...`

**Reply format**
- `...`

**Fallback**
- `...`
