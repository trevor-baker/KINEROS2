---
name: line-endings
description: KINEROS2 line-ending policy. Fortran source files (src/*.for, *.f90, *.f) keep whatever line endings they already have (currently CRLF); every other file (AGENTS.md, skills, posit/session_history, posit/archive, task_backlog, scripts, docs) is LF-only. Use whenever reading, writing, or editing any text/code file in this project, especially before exact-string edits.
---

# Line Endings

Project override of the global Windows CRLF default (project memory wins).

- **Fortran** (`.for`, `.f90`, `.f`, etc.): preserve the file's existing endings. Check first (`grep -c $'\r' file` vs `wc -l`). Sampled `src/` files are all CRLF. Never convert them; never introduce mixed endings. New Fortran files: match neighbouring files (CRLF).
- **Everything else** (memory, skills, session histories, archive, backlog, new scripts/docs): **LF-only**. New files must be written LF. When editing an existing non-Fortran file with CRLF, convert the whole file to LF in the same change.
- If an exact-string `edit` fails unexpectedly, check for CRLF before assuming the match is wrong.
- No retroactive sweep: convert non-Fortran files only when touched for another reason.
