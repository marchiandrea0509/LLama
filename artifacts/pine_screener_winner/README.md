# Pine Screener Winner Artifacts

This folder keeps the *live* winner package that the Discord helper scripts expect.

## Keep at top level

- `latest_manifest.json`
- `latest_table.txt`
- the current `*_Openclaw-structure.png` screenshots referenced by the manifest
- the matching `*_Openclaw-structure_meta.json` files
- `capture.log` if it still reflects the latest useful capture run

## Archive instead of mixing old files with live ones

Move stale or superseded files into `archive/YYYY-MM-DD_cleanup/`, especially:

- test logs like `capture_test.log`
- pre-layout screenshots such as non-`_Openclaw-structure` variants
- older winner packages no longer referenced by `latest_manifest.json`

## Safety rule

Before pruning, check `latest_manifest.json` and keep the files it points to live at the top level.

## Cron delivery note

The live package in this folder is the source of truth for the llama workspace, but cron delivery should mirror the current screenshots into the canonical OpenClaw workspace tree before emitting `MEDIA:` lines:

- `C:\Users\anmar\.openclaw\workspace\artifacts\llama_screener_winner\`

That avoids `LocalMediaAccessError` from OpenClaw's default local-media allowlist, which can reject sibling roots like `workspace-llama` even when the files themselves are valid.
