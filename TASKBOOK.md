# TASKBOOK.md - Known Tasks for Llamy

Use this file for repeatable tasks that should be handled the same way every time.

## Rules

- Prefer the known task recipe over improvising.
- For exact command tasks, use `exec` directly.
- For fragile status lookups, prefer a wrapper script if one exists.
- If the task says "reply with exactly X", the final reply must be exactly `X`.
- If a known task fails, say briefly that it failed instead of explaining tools in the abstract.
- For trigger-based known tasks, do not narrate workflow or tool usage.
- Never mention `TASKBOOK.md`, scripts, polling, background runs, or internal execution steps in the user-visible reply.
- For known tasks, the final reply must be only the task result or the exact fallback line.

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
- Treat these trigger phrases as a request for Pine screener output plus winner screenshots on 4H and 1D.
- Do not ask clarifying questions when one of these trigger phrases is used by itself.
- For the plain phrase `pine screener with winner screenshot`, prefer the latest good local winner artifacts whenever they exist.
- A cached winner package is only valid if its manifest explicitly says `layout = Openclaw-structure`.
- For the explicit phrase `refresh pine screener with winner screenshot`, force a fresh rerun.

**Action**
1. If the trigger is `refresh pine screener with winner screenshot`, use `exec` to run:
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\run_pine_screener_with_winner_shots.ps1`
2. Otherwise use `exec` to run:
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_pine_screener_with_winner_shots_status.ps1`
3. Then use `exec` to run:
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_latest_winner_media_refs.ps1`
3. Parse the JSON output.
4. Reply in the current chat with:
   - only the table output from the wrapper
   - then the two `MEDIA:./...` lines from `media4H` and `media1D`
   - no extra commentary

**Reply format**
- The text body must be only the table followed by the two `MEDIA:./...` lines.
- Use `MEDIA:./relative/path.png` for the 4H and 1D winner screenshots.
- Do not add intro text.
- Do not add labels like `Winner:` or `Attached:`.
- Do not explain the pipeline.
- If you do not have valid `MEDIA:./...` lines for both images, reply exactly: `Pine screener winner screenshot failed.`

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
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_latest_winner_media_refs.ps1`
2. Parse the JSON output.
3. Reply with only:
   - `<winner> 4H and 1D`
   - then the two `MEDIA:./...` lines from `media4H` and `media1D`

**Reply format**
- Keep the text body minimal.
- Use only the winner line plus the two `MEDIA:./...` lines.
- Do not claim attachments unless both media lines are present.

**Fallback**
- `Winner screenshots unavailable.`

### 10) Manual llama screener dispatch

**Trigger examples**
- `trigger llama screener`
- `run llama screener now`
- `send llama screener`
- `refresh llama screener now`

**Interpretation rule**
- Treat these phrases as a request made from the `#llama` room to run a fresh screener dispatch now.
- Do not use `cron run` or create a one-shot cron job for this manual path.
- First check that the configured Qwen/Ollama backend is reachable.
- Then build the final delivery body locally and forward it to the `#llama-screener` room session.
- The current room only gets a short acknowledgement.

**Action**
1. Use `exec` to run:
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\test_qwen_backend.ps1`
2. If step 1 fails, reply exactly:
   - `Qwen host offline. Not sent.`
3. Use `exec` to run:
   - `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_llama_screener_cron_delivery.ps1`
4. If step 3 fails or stdout is empty, reply exactly:
   - `Llama screener dispatch failed.`
5. Use `sessions_send` to send this message to session key `agent:llama:discord:channel:1495366850450558986`:
   - `Reply with exactly the following content and nothing else:`
   - then the full stdout from step 3
6. If `sessions_send` succeeds, reply exactly:
   - `Sent to #llama-screener.`

**Reply format**
- Reply in the current chat with only the acknowledgement or fallback line.
- Do not include workflow explanation.

**Fallback**
- `Qwen host offline. Not sent.`
- `Llama screener dispatch failed.`
- `I couldn't send llama screener right now.`

### 11) Pre-compaction memory flush

**Trigger examples**
- `Pre-compaction memory flush. Store durable memories now ...`

**Interpretation rule**
- Treat this as a maintenance turn, not a normal user conversation.
- Do not get stuck rereading the same file repeatedly.
- Read the current daily memory file at most once.
- Only store a memory if there is a genuinely durable new fact from the recent conversation that is worth keeping.
- If there is nothing clearly worth keeping, reply exactly: `NO_REPLY`

**Action**
1. If `memory/YYYY-MM-DD.md` does not exist, create it only if there is a real durable memory to save.
2. If there is a real durable memory to save, append it once.
3. Prefer a single append operation via `exec`/PowerShell `Add-Content` for append-only writes.
4. Do not loop between `read` and `write` decisions.
5. Do not explain your reasoning to the user.

**Reply format**
- If nothing durable should be saved, reply exactly: `NO_REPLY`
- If a save was made successfully, also reply exactly: `NO_REPLY`

**Fallback**
- `NO_REPLY`

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
