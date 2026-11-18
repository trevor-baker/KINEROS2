---
name: k2-h1d-coupling
description: Reference for the KINEROS2 (K2) side of the K2-HYDRUS-1D coupling (branch h1d-coupling) - the coupled-mode file hooks in src/plane.for (k2_infil.in, k2_state.in/out, k2_period.out), the gfortran build (build/build_k2_h1d.sh, x64/k2_h1d.exe), the stdin run protocol, and the R chained-run helper R/k2_chain.R. Use when editing plane.for/K2shell for coupling, building or running k2_h1d.exe, writing the R coupler, or testing restart equivalence.
---

# K2-H1D coupling (K2 side)

Plan file (outside this repo): `C:/Users/t/Documents/iegsoil_dev/IEGsoil/.posit/assistant/plans/2026-11-10-1546-plan.md`. Phases 0-2 (K2 edits + restart-equivalence gates) done; later phases are the R coupler and HYDRUS side.

Full details (build flags, source list, stdin order, file formats, verified tests, known issues): **`build/BUILD_NOTES.md`** - read it rather than duplicating here.

## Key points

- Hooks live only in `src/plane.for`; all inactive when no `k2_*` files exist (stock behaviour preserved).
- `k2_infil.in` present = coupled mode: imposed per-node `fav` (m/s, constant per run) replaces `infilt`, no dry-plane early exit.
- State hand-off between periods: `k2_state.out` -> `k2_state.in`. `qbal` resets each K2 call, so accumulate volumes in R; `stor_vol` is end-of-period storage (not additive).
- K2 reads answers from stdin (`-s kin.fil` doesn't work); rain file must be re-zeroed per period (`k2_shift_rain()` in `R/k2_chain.R`).
- `R/k2_chain.R`: `k2_chain(exe, par, rain, breaks, fav, workdir)` - `fav` a vector or `function(i, state)`.
- Tests that write files: run in repo (e.g. `build/chain_work`) and delete afterwards; Fortran edits must keep CRLF (see `line-endings` skill; use perl/byte-safe edits, `sed -i` can convert the whole file).
- `maxnk = 41` (`module k2dims` in `src/k2mods.for`) dimensions all node arrays; `k2_infil.in` line 1 overrides plane `nk` (5..maxnk) - opt-in, stock cap 15 otherwise (channels/pipes/urban stay 15). `x64/k2_h1d.exe` and `build/mod/` are gitignored; rebuild with `build/build_k2_h1d.sh`. Bounds-check build recipe in `build/BUILD_NOTES.md`.
- `src/rain.for`: hyetograph times round to 0.1 min normally, but to 1e-6 min when `k2_infil.in` exists (coupled mode; collisions bumped by 1e-6). Allows sub-0.05-min periods. `k2_write_pre` writes times `%.8f`. Verified: EX1 without `k2_infil.in` identical to old exe; rain_vol = rain x L x dt for dt 1/60..1 min (2e-5 rel at 1/60, real*4 limit).
- `iter()` tolerances (coupled only): plane `erpaub`/`errh2` solves use tol 1e-10, rtol 1e-8 when `k2_infil.in` exists (stock 1e-7/1e-4 otherwise; other modules unchanged). Env overrides read at startup in `plane.for`: `K2_ITER_STOCK=1` forces stock; `K2_ITER_TOL=<real>` replaces the 1e-10 (precedence STOCK > TOL > default). `errh2` no-convergence stop prints the tol to stdout (`fort.6`). EX1 fails at 1e-10, passes at 1e-9. Detail: `posit/archive/2026-11-18-iter-tolerance.md`.
- Gotcha: K2 clamps `h >= 0`, so imposed `fav` beyond available water loses mass (item on hold in `posit/task_backlog.md`).
