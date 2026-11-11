# k2_h1d.exe build notes

Modified KINEROS2 (K2) build for the R-driven HYDRUS-1D coupling (Chen et al. 2022). Branch: `h1d-coupling`. Stock `x64/k2_x64.exe` is never overwritten.

## Build

```
bash build/build_k2_h1d.sh      # from repo root; output x64/k2_h1d.exe
```

- Compiler: gfortran 13.x (Rtools44) must be on PATH. The source was originally Intel-Fortran built.
- Flags: `-std=legacy -w -ffixed-line-length-none -fno-range-check -fallow-argument-mismatch -fno-automatic -O1 -static`; `.mod` files go to `build/mod/`.
- Source files compiled: `k2mods.for kinsed.f90 K2shell.f90 adder.for channel_tab.for diverter.f90 infilt_test.for inject.for iter8.for miscel.for pchip.f90 pipe.for plane.for pond.for rain.for reader.for urban.for writer.for kinsed_rhem.for kinsed_smith_new.for kinsed_wepp.for`.
- Deliberately excluded: `fmt10_new.for` (duplicates `fmt10` in `miscel.for`) and `sedbf.for` (duplicates the `sedbf_smith` entry in `kinsed_smith_new.for`).
- `infilt_test.for` stands in for the missing `infilt.for`.
- gfortran-specific fix in the repo: `kinsed_wepp.for` line 155, `reshape(..., (/5,1/))` changed to `(/5/)`.
- Line endings: Fortran files are CRLF and must stay CRLF (see `line-endings` skill).

## Running K2

`-s kin.fil` does not work. Answers go on stdin, one per line, in this order:

1. `.par` file
2. `.pre` (rain) file
3. output file
4. title
5. duration `tfin` (min)
6. time step (min)
7. `n` (Courant adjustment)
8. `y`/`n` sediment
9. `n` (multipliers)
10. `n` (tabular summary)

Delete leftover `kin.fil` and `mult.fil` before each run. The R helper `R/k2_chain.R` does all this.

## Coupled-mode hooks (`plane.for`)

All hooks are inactive when the extra files are absent. With no `k2_*` files, EX1 output is identical to the stock-source build (and matches `k2_x64.exe` to about 1e-6 relative).

| File | Direction | Content |
|---|---|---|
| `k2_infil.in` | in | line 1: `nk`; line 2: `fav(1:nk)` (m/s, constant for the run). Replaces the `infilt` call and also turns on coupled mode (no dry-plane early exit). Node 1 is ignored. |
| `k2_state.in` | in | line 1: `nk`; then one row per node: `h q topw xc`. Restarts the plane (`unif = .false.` if any `h > 0`). |
| `k2_state.out` | out | same layout as `k2_state.in`, written at end of run (coupled mode only). |
| `k2_period.out` | out | header, then `rain_vol infil_vol stor_vol out_vol hmean out_q`. Volumes are per run (`qbal` resets each call; accumulate in R). `stor_vol` is end-of-period storage, not additive. `out_q` is outflow rate at period end. |

A node-count mismatch in either input file stops K2 with an error.

## Verified so far (EX1, `sample_input/`)

- Stock-equivalence: no extra files, output equals stock-source build; differs from `k2_x64.exe` only at about 1e-6 relative.
- Restart equivalence: 1, 2 and 4 chained periods with constant `fav` give identical final state; rain, infiltration and outflow volumes agree to about 1e-6 relative.
- Time-varying `fav` injection (node- and time-varying): 3 vs 6 periods give the same state (max diff 6e-8) and the same water balance.

## Known issues

- Water-balance residual: about 0.2% of rain on EX1 even with no dry-out (probably K2's storage estimate; unconfirmed). Larger losses (about 13% in one test) when a fixed `fav` dries the plane mid-step, because K2 clamps `h` at 0. Under review; the paper handles this on the H1D side (Eq. 4 flux cap) and via smaller dtp.
- Rain files must be shifted per period (`k2_shift_rain()` in `R/k2_chain.R`).
