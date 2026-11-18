# 2026-11-18 - coupled-mode iter() tolerance experiment

## Item 5 - tight iter() tolerances vs steady mass-balance bias

Background: coupled 24 m plane, slope 0.5, rain 3.3e-5 m/min, RELIEF = 0, infil 1.5e-7 m/s. Steady-rain outflow exceeds (rain - infil) by 1.9% of excess at nk = 13 (3.3% at nk 7, 0.70% at nk 41); negligible at rain 3.3e-4. Steady box scheme telescopes exactly, so the bias must come from solver error or cutoffs.

Suspect: `iter()` in `src/miscel.for`, stock `tol = 1e-7`, `rtol = 1e-4`. Plane depths at low rain are 1e-5..1e-4 m, so the absolute residual test applies and per-cell residuals up to ~25% of ql pass.

What landed (source uncommitted; `x64/k2_h1d.exe` rebuilt 2026-11-17 23:45, contains both env var names):
- Coupled mode (`k2_infil.in` present) uses tol 1e-10, rtol 1e-8 for the plane `erpaub` and `errh2` iter calls only. Channel/pipe/pond/urban calls and all non-coupled runs stay stock.
- `K2_ITER_STOCK=1` forces stock tolerances even when coupled (paired comparisons with one exe).
- `K2_ITER_TOL=<real >0>` replaces the 1e-10 tight tol (rtol stays 1e-8). Invalid/<=0 ignored. Precedence: STOCK=1 > ITER_TOL > default tight.
- The `errh2` no-convergence stop writes `tol=<value>` to stdout (fort.6).
- Module vars in `k2dims`: `iter_tight`, `iter_tol_user`, `iter_tol_used`. `plane.for` reads the env vars once at startup.

Evidence (EX1, 60 min, 13-node k2_infil.in at 1.5e-7, first iter() call printed):
| case | tol | rtol |
|---|---|---|
| coupled, unset | 1e-10 | 1e-8 (EX1 then stops: no convergence errh2, tol=1e-10) |
| K2_ITER_TOL=1e-9 | 1e-9 | 1e-8 (completes) |
| K2_ITER_TOL=1e-7 | 1e-7 | 1e-8 |
| STOCK=1 + TOL=1e-9 | 1e-7 | 1e-4 |
| TOL=abc or -1 | 1e-10 | 1e-8 |
| non-coupled + TOL=1e-9 | 1e-7 | 1e-4 |

Reported by user (not tested here): with RELIEF = 2 in coupled mode, tight tol hits the 50-iteration cap ("no convergence (errh2)"); stock passes. R side plans to retry failed periods with tol raised 1e-10 -> 1e-7 via K2_ITER_TOL.

Caveats: rtol 1e-8 is below real*4 epsilon so the relative test may never trigger; the 1e-10 absolute residual may be near the real*4 noise floor for some cases (hence the failures). The bias comparison (steady_bias_pct vs -1.92 at nk = 13, IEGsoil `dev/H1D_K2/test_hyd_phase6c.R`) has NOT been run.

Cutoffs reviewed in `plane.for` (report only, unchanged, not verified by test):
- `if (h2jp1 .lt. 1.E-7) h2jp1 = 0.` destroys mass but only below 1e-7 m depth; unlikely at 1e-5..1e-4 m, possible at upstream nodes near the dry edge at low rain.
- `ql(j,1) = 0.` in the dry branch (qlav <= 1e-11) uses j where jp1 may be intended; likely negligible effect.
- Possible diagnostic: temporary counter for how often the 1e-7 h2 cutoff fires in the nk = 13 run.

Gotchas: K2 stdout goes to `fort.6` in the run dir. Scratch run recipe: copy `sample_input/EX1.PAR`/`EX1.PRE` + k2_infil.in to a dir under `build/`, stdin `EX1.PAR, EX1.PRE, out.txt, test, 60, 1, n, n, n, n`.
