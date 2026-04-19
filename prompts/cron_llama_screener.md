Run the Llama screener thread update and deliver the final user-facing result to the configured thread only.

Do exactly this:
1. Run:
   `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_llama_room_status.ps1`
2. If that command fails, or if its output does not contain `Session: present`, reply with exactly:
   `llama does not respond`
   and stop.
3. Run:
   `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_pine_screener_with_winner_shots_status.ps1`
4. If that command fails, reply with exactly:
   `llama does not respond`
   and stop.
5. Run:
   `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_latest_winner_media_refs.ps1`
6. If that command fails, reply with exactly:
   `llama does not respond`
   and stop.
7. Parse the JSON from step 5.
8. Final reply must be exactly:
   - the table output from step 3
   - then `media4H` on its own line
   - then `media1D` on its own line
9. Do not add any intro text, labels, winner summaries, or commentary.
10. Do not say `attached above`.

If anything is ambiguous or missing, reply exactly:
`llama does not respond`
