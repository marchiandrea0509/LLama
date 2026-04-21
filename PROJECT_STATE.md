# PROJECT_STATE.md

## Project

- Name: Llama
- Purpose: Wire the Llama model as the main agent for this room for simple tasks or maintenance when GPT usage allowance is at 0%; keep GPT-5.4 as the active model until Llama is set up.
- Agent ID: llama
- Workspace: C:\Users\anmar\.openclaw\workspace-llama
- Bootstrap Status: ready
- Validation Result: pass

## Bootstrap summary

- Created By: openclaw-project-bootstrap
- Created At: 2026-04-18T10:56:23+02:00
- Last Verified: 2026-04-18T10:56:23+02:00
- Standard Workspace Seed: complete
- Current Blocker: none

## Routing

- Discord Guild ID: 1487584401872261323
- Discord Channel ID: 1494983758745698417
- Discord Mode: apply
- Discord Status: applied
- Mentor Thread: Llama-lab (`1496002959660552252`) bound to agent `llama-lab`
- Mentor Policy: keep `#llama` on `llama` only; use `Llama-lab` for GPT-5.4 coaching on the same workspace

## Bootstrap checklist

- [x] Agent registered in OpenClaw CLI
- [x] Workspace path verified
- [x] Standard OpenClaw workspace files present or intentionally skipped
- [x] PROJECT_STATE.md created
- [x] SESSION_START.txt created
- [x] Discord binding prepared, applied, or explicitly not requested
- [x] Validation checklist passed

## Current focus

Wire the Llama model as the main agent for this room for simple tasks or maintenance when GPT usage allowance is at 0%, while keeping GPT-5.4 active until Llama is ready.

## Decisions

- Keep this project agent focused on: wiring a future Llama-backed room agent while using GPT-5.4 as the active model for now.
- Treat Discord `prepare` and `apply` as different states.
- Do not switch the room to a Llama model until the Llama path is explicitly set up and tested.
- Do not run `openclaw setup --workspace` for this project agent unless explicitly requested.
- 2026-04-18: Added an explicit workspace rule for Discord replies: answer the current room directly and do not use `sessions_send` for the current inbound message.
- 2026-04-18: Added an explicit workspace rule for command execution: when given `Run exactly: <command>`, use `exec` with that exact command instead of explaining how commands could be run.
- 2026-04-18: Added `TASKBOOK.md` and a helper script (`scripts/get_openclaw_usage.ps1`) so Gray can teach Llamy repeatable tasks through small playbooks plus wrapper scripts.
- 2026-04-18: Expanded Llamy's taught-task set with two more wrapper-script tasks: compact OpenClaw health (`scripts/get_openclaw_health.ps1`) and `#llama` room status (`scripts/get_llama_room_status.ps1`).

## Next actions

- none

## Notes

- Created by the OpenClaw project bootstrap workflow.
- `openclaw agents add` may already seed the standard workspace baseline; verify it before creating extra files.
- Update this file when scope, routing, blockers, or validation status changes.
- 2026-04-18 diagnostic: inbound Discord routing to `#llama` works; observed failure was reply-path misuse inside the agent (`sessions_send` called with a Discord message ID instead of replying directly in-channel).
