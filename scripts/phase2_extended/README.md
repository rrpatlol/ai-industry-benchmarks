# Extended Phase 2 Benchmarks

This directory contains scripts to run extended parameter sweeps on STREAM, OSU, and HPL benchmarks, targeting aerospace-relevant workload characterization.

## Scripts

- `extended_stream.sh`: STREAM with varying thread counts (1, 4, 22, 44, 88) and large array sizes (200M).
- `extended_osu.sh`: OSU microbenchmarks with full message size sweep (1 B to 128 MiB).
- `extended_hpl.sh`: HPL with larger problem sizes (N=75k, 100k, 125k, 150k).

## Usage

```bash
# Run extended STREAM
bash scripts/phase2_extended/extended_stream.sh /path/to/output

# Run extended OSU
bash scripts/phase2_extended/extended_osu.sh /path/to/output

# Run extended HPL (long-running: 4-8 hours)
bash scripts/phase2_extended/extended_hpl.sh /path/to/output
```

## Analysis

See [dmr-88_phase2_extended_analysis.md](../../docs/aerospace/results/dmr-88_phase2_extended_analysis.md) for expected performance and aerospace workload implications.
