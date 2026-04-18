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

**Interpretation rule**
- Treat these trigger phrases as a request for the **current local Pine screener status table**.
- Do **not** reinterpret them as a request to build, design, or explain a TradingView/Pine Script screener.
- Do **not** ask clarifying questions when one of these trigger phrases is used by itself.
- Assume the user wants the latest available local screener table immediately.
- For these plain trigger phrases, prefer the latest cached/local result over rerunning the export.

**Action**
- Use `exec` to run:
  - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_pine_screener_status.ps1`

**Reply format**
- Return only the script output.
- Do not add intro text.
- Do not summarize the table.
- Do not explain what the screener is.

**Fallback**
- `Pine screener unavailable.`

### 7) Pine screener export / refresh

**Trigger examples**
- `refresh pine screener`
- `rerun pine screener`
- `run pine screener export`
- `export pine screener`
- `update pine screener`

**Interpretation rule**
- Treat these trigger phrases as an explicit request to rerun the local TradingView export pipeline.
- Use the export wrapper, not the cached-status wrapper.
- Do not ask clarifying questions when one of these trigger phrases is used by itself.

**Action**
- Use `exec` to run:
  - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\run_pine_screener_export.ps1`

**Reply format**
- Return only the resulting table output from the fresh export.
- Do not add intro text.
- Do not summarize the table.
- Do not explain the export pipeline.

**Fallback**
- `Pine screener export failed.`

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
