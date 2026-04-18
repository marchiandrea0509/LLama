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
- If the latest cached/local result is older than 1 hour, do not print the stale table; reply exactly: `Pine screener stale. Run refresh pine screener.`

**Action**
- Use `exec` to run:
  - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_pine_screener_status.ps1`

**Reply format**
- Return only the script output.
- Do not add intro text.
- Do not summarize the table.
- Do not explain what the screener is.

**Fallback**
- `Pine screener stale. Run refresh pine screener.` when the latest local report is older than 1 hour
- `Pine screener unavailable.` when no usable local report exists

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

### 8) Pine screener with winner screenshot

**Trigger examples**
- `pine screener with winner screenshot`
- `refresh pine screener with winner screenshot`
- `winner screenshot`
- `run pine screener with winner screenshot`

**Interpretation rule**
- Treat these trigger phrases as an explicit request for a fresh Pine screener run plus screenshots of the top winner on 4H and 1D.
- Do not ask clarifying questions when one of these trigger phrases is used by itself.
- Use the combined wrapper, not the cached-status wrapper.

**Action**
1. Use `exec` to run:
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\run_pine_screener_with_winner_shots.ps1`
2. Then read these files:
   - `C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner\latest_manifest.json`
   - the image at `image4H` from that manifest
   - the image at `image1D` from that manifest
3. Use `read` on the two image paths from the manifest in the same turn so they become real message attachments.
4. Reply in the current chat with:
   - only the table output from the wrapper
   - plus the two screenshot attachments from those `read` calls
   - no extra commentary

**Reply format**
- The text body must be only the table.
- Attach the winner 4H screenshot and the winner 1D screenshot via `read`.
- Do not add intro text.
- Do not add labels like `Winner:` or `Attached:`.
- Do not explain the pipeline.
- If you did not successfully `read` both image files in the same turn, do not claim they are attached.

**Fallback**
- `Pine screener winner screenshot failed.`

### 9) Winner screenshots only

**Trigger examples**
- `show winner screenshots`
- `winner screenshots only`
- `attach winner screenshots`
- `show the winner screenshots`

**Interpretation rule**
- Treat these trigger phrases as a request to attach only the latest winner screenshots from the most recent successful screener-with-screenshots run.
- Do not rerun the screener.
- Do not add summary text.

**Action**
1. Use `exec` to run:
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_latest_winner_screenshots.ps1`
2. Parse the JSON output.
3. Use `read` on `image4H` and `image1D` in the same turn.
4. Reply with only a minimal caption:
   - `<winner> 4H and 1D`

**Reply format**
- Attach only the two images.
- Keep the text body minimal.
- Do not claim attachments unless both `read` calls succeeded.

**Fallback**
- `Winner screenshots unavailable.`

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
