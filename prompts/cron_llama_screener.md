Run the Llama screener thread update and return only the final delivery body.

Do exactly this:
1. Run:
   `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_llama_room_status.ps1`
2. If step 1 fails, or its output does not contain `Session: present`, reply exactly:
   `llama does not respond`
3. Run:
   `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_pine_screener_with_winner_shots_status.ps1`
4. If step 3 fails, or the returned table text is empty, reply exactly:
   `llama does not respond`
5. Run:
   `powershell -ExecutionPolicy Bypass -File C:\Users\anmar\.openclaw\workspace-llama\scripts\get_latest_winner_media_refs.ps1`
6. If step 5 fails, reply exactly:
   `llama does not respond`
7. Parse the JSON from step 5 and extract the literal string values of `media4H` and `media1D`.
8. If either media value is missing or does not start with `MEDIA:./artifacts/`, reply exactly:
   `llama does not respond`
9. Final reply must be exactly:
   - the full table text from step 3
   - then the literal `media4H` value on its own line
   - then the literal `media1D` value on its own line
10. Do not add labels, code fences, commentary, or any extra text.

If anything is ambiguous or missing, reply exactly:
`llama does not respond`