# Session History

One file per `/savememory` call: `YYYYMMDD-HHMM.md`, named by the local date/time
the file was written (24-hour clock), **not** a sequential counter — this project
has multiple contributors working on different branches, so a shared incrementing
number (`session_NN`) can't be kept consistent across them. Written fresh every
time — never appended to or merged into an existing file, even when the session is
a direct continuation of the same topic as a prior one.

**Write-only from the assistant's perspective — do not read these back in at the
start of a session.** They exist for the user's own tracking. Keep each file
concise (target ~50 lines, cap ~100): highlight major steps and key
uncertainties, not a message-by-message log.

Full protocol: `.posit/assistant/skills/session-protocol/SKILL.md`.
