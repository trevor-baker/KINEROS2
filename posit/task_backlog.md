# Task Backlog

This is longer-horizon reference material, not needed every session — AGENTS.md's "Next Session Tasks" carries the short, currently-active list.

## Next Session Tasks (active — full detail)

*(AGENTS.md carries only a one-line, <20-word pointer to each numbered item below. Remove an item here — and its pointer in AGENTS.md — only after the user confirms it's done. For a "✅ landed in source, not yet run/verified" item: keep the entry itself to one sentence with a pointer to a dated `posit/archive/*.md` file for the full narrative — see `session-protocol` skill, "Pending-Verification Item Style" — unless it's flagged as an active/concurrent investigation, which stays untouched until it settles.)*

1. **Commit the K2 coupling work.** On branch `h1d-coupling`, uncommitted: `src/plane.for`, `src/kinsed_wepp.for` (one-line gfortran fix), `R/k2_chain.R`, `build/`, `x64/k2_h1d.exe`, `AGENTS.md`, `.posit/`, `posit/`. User said do not commit until asked. Decide whether to track or ignore `x64/k2_h1d.exe` and `build/mod/` (not in `.gitignore`).
2. **Continue the plan beyond Phase 2** (`iegsoil_dev/IEGsoil/.posit/assistant/plans/2026-11-10-1546-plan.md`): R coupler (`hyd_k2Couple()`, built on `R/k2_chain.R`) and the HYDRUS side. Re-read the plan for phase details.
3. **Item 6 water-balance leak - ON HOLD (user said hold off follow-up).** K2 clamps `h >= 0`, so fixed `fav` above available water loses mass (about 13% in a plane-dry test; about 0.2% baseline residual on EX1, source unconfirmed). Intended fix per user: R-side flux cap / rerun per the paper (Eq. 4); smaller dtp is complementary - compare both in the later test phase. Detail: `build/BUILD_NOTES.md`, "Known issues".
4. **Minor gaps:** bit-for-bit check of `k2_h1d.exe` vs `x64/k2_x64.exe` (so far only vs gfortran stock build, about 1e-6 relative); confirm whether the baseline EX1 residual (~2-3 m3) is K2's own storage estimate.
