#!/usr/bin/env bash
# Build the H1D-coupling K2 variant (x64/k2_h1d.exe) with gfortran (Rtools44).
# Run from the repo root. Stock x64/k2_x64.exe is not touched.
# fmt10_new.for and sedbf.for are excluded on purpose: miscel.for defines
# fmt10 and kinsed_smith_new.for defines the sedbf_smith entry point.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$root/build/mod"
cd "$root/src"
gfortran -std=legacy -w -ffixed-line-length-none -fno-range-check \
  -fallow-argument-mismatch -fno-automatic -O1 -static -J ../build/mod \
  -o ../x64/k2_h1d.exe \
  k2mods.for kinsed.f90 K2shell.f90 adder.for channel_tab.for diverter.f90 \
  infilt_test.for inject.for iter8.for miscel.for pchip.f90 pipe.for \
  plane.for pond.for rain.for reader.for urban.for writer.for \
  kinsed_rhem.for kinsed_smith_new.for kinsed_wepp.for
echo "built x64/k2_h1d.exe"
