---
name: session-protocol
description: Protocol for the /savememory command (a mandatory three-step operation — route content, update AGENTS.md, AND write a new per-session history file; the history file is not optional) and for task_backlog.md's "pending-verification item" style (landed-but-unrun/unverified fixes get a one-line pointer, full narrative moved to a dated archive file). Use when the user types /savememory, asks how session history / backlog items are tracked, or when trimming/decluttering task_backlog.md.
---

# Session Protocol

## Recognizing a `/savememory` invocation even when the literal token isn't visible

Some clients expand or paraphrase slash commands before they reach the model, so a `/savememory` call may arrive as plain prose instead of the literal token — e.g. "update the memory file for this project," "save progress," "save memory." **Any message that reads as a session-end memory-save request must be treated as a full `/savememory` invocation by default** (all three steps below), not a routine AGENTS.md tweak. Routine, narrowly-scoped memory edits (e.g. "add this one decision to AGENTS.md", "update the pointer for NST 1") stay lightweight — but a bare, general "update the memory file" request is presumptively the full protocol. If genuinely unsure which the user wants, ask rather than silently picking the lighter option.

## `/savememory` Protocol

**`/savememory` is never "just update AGENTS.md."** Writing a new `posit/session_history/YYYYMMDD-HHMM.md` file (step 3 below) is just as mandatory as the AGENTS.md edit, not an optional extra reserved for "notable" sessions. Doing only one of the two required writes is an incomplete execution of the command, to be corrected in the same turn — not deferred.

`/savememory` is a three-step operation, every time, no exceptions:

1. **Route each piece of new content per AGENTS.md's "Where New Content Goes" rule** before writing anything — do not default to appending everything to AGENTS.md just because it's the file already open. Landed features/conventions/reference material go to a matching skill (or a new one); pure narrative goes to archive; only the current restart-critical state goes in AGENTS.md itself.
2. **Update `AGENTS.md`'s "Where We Left Off — RESTART HERE" and, if applicable, "Next Session Tasks"** — as an edit, not just an addition: anything now resolved, landed, or superseded by this session's work must be **moved out** to `posit/archive/`, not appended to and left growing. If AGENTS.md exceeds ~100 lines after this edit, trim further before moving on.
3. **Write a new per-session history file** to `posit/session_history/YYYYMMDD-HHMM.md`, timestamped from the current date/time (local time, 24-hour clock) rather than a sequential number — this project has multiple contributors working on different branches, so a shared incrementing counter (`session_NN`) can't be kept consistent across them. **This must always be a brand-new file, created every single time `/savememory` runs — never appended to, merged into, or folded into an existing file (including archive files), regardless of topic overlap with a prior session.** Topic-organized narrative belongs in `posit/archive/` (step 1); the per-session log still gets its own file. Keep it concise — highlight major steps and key uncertainties, not a message-by-message log. Target ~50 lines, cap at 100. **Do not read these files back in at the start of a session** — they exist purely for the user's own tracking, not as assistant context.

**Before replying, explicitly verify steps 2 and 3 were actually done** this turn (edits/writes occurred) — don't assume it happened just because it's routine. Confirm step 3 created a **new** file rather than editing an existing one (check via `ls`/tool result, not assumption). If either step was skipped, or step 3 modified an existing file instead of creating a new one, fix it before responding.

**`/savememory` response should be terse:** after doing the update, reply with only a one-sentence confirmation that any specific instructions given alongside the `/savememory` call were completed, plus a note if anything was moved to a skill/archive. Skip full summaries of what changed — the user will ask if they want details.

## Backfilling a noticed missing session_history file

If a `/savememory` call (or any check of `posit/session_history/`) discovers that a past session referenced in AGENTS.md or a skill has no corresponding `posit/session_history/*.md` file (i.e. `/savememory` was apparently never invoked for that session, or its step 3 was skipped), write an **abbreviated** session_history file for the missing session as part of that same `/savememory` call, reconstructed from whatever can be inferred from AGENTS.md text, skill entries, or other artifacts referencing that session. Name the backfilled file with the best-guess timestamp for when that session actually happened (fall back to a plausible date with `HHMM` such as `0000` and a note in "File origin" that the time is approximate, if the exact time can't be inferred).

Requirements for a backfilled file:
- Open with a **"File origin"** section stating plainly that the file was created retroactively (name the session that did the backfill), that no session_history file existed at the time, and that content is reconstructed from remnants rather than a first-hand narrative — flag that it may be incomplete.
- Reconstruct "what can be inferred happened" from the actual referencing text, citing which file the detail came from where useful, rather than inventing detail.
- Do not guess at content with no supporting reference — omit rather than fabricate.

**Only backfill gaps discovered incidentally going forward — do not proactively audit past sessions for gaps.**

## Where superseded/landed session narrative goes

Once a session's findings are folded into a "LANDED" feature writeup in a reference skill, or superseded by later work, move the narrative out of AGENTS.md's "Where We Left Off" section and into `posit/archive/*.md` — AGENTS.md's restart section should only ever contain what's needed to resume *current* active work, not a running log of past sessions.

## Pending-Verification Item Style (task_backlog.md)

`posit/task_backlog.md`'s "Next Session Tasks (active — full detail)" section is meant to hold enough detail that a future session can act on an item without re-deriving it — but for a fix that has already **landed in source** and is merely waiting on a rerun/manual check to confirm, the multi-paragraph root-cause story is not what a future session needs to act on; it only needs to know *that* something landed, *what* to check to confirm it, and *where* the full story lives if something looks wrong.

**Convention, applied going forward whenever a task_backlog item is first marked "✅ landed in source, not yet run/verified":**

1. Write the full narrative (root cause, before/after detail, test-case specifics, caveats) into a dated archive file — reuse a current dated file for the session if one already exists for this purpose, or start a new one. Give each fix its own `## Item N — short title` heading matching the task_backlog item number, so the pointer below resolves unambiguously.
2. In `task_backlog.md`, reduce the item to one sentence in this shape:
   `N. ✅ **[short title] — landed in source, not yet run/verified.** [One-line summary of what it covers, if useful for scanning.] Full detail: posit/archive/YYYY-MM-DD-....md, item N.`
3. Do **not** archive-and-shorten an item that's still under active, unresolved investigation — that belongs in archive/session-history only once it settles, not while still being actively worked.
4. Once the verification actually happens and the fix is confirmed (or found to need more work), delete the one-liner entirely rather than leaving it. If verification surfaces a problem, that becomes a fresh, current entry (new narrative if needed), not a re-inflation of the old pointer.

This mirrors (and is a specific instance of) the general AGENTS.md "Where New Content Goes" rule: full story → archive, one-line pointer → the file read every session.

## Bundling Multiple Pending-Verification Items Under One Follow-Up

When several pending-verification items all wait on the *same* follow-up (e.g. five different fixes all get verified the next time a particular script/workflow is run end-to-end), don't restate "needs a full X run to verify — bundle with Next Session Task N" separately in each item.

**Convention instead:**

1. Pick the master Next Session Task item that represents the actual follow-up step. Add one line to *that* item only: `**Bundled landed-but-unrun fixes this run will also verify:** 12, 14, 15, ...` (a plain list of item numbers — the reader follows the numbers to each item's own one-liner).
2. In each individual pending-verification item, replace the restated follow-up sentence with a short parenthetical: `*(Bundled under Next Session Task N.)*`
3. If an item genuinely needs a *second*, distinct step beyond the shared follow-up, keep that extra clause in the parenthetical — only the redundant boilerplate gets removed.
4. When a new pending-verification item is added later and it shares a follow-up with existing bundled items, add its number to the master item's bundled list in the same edit — don't let the master list go stale.
