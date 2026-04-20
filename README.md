# ai-industry-benchmarks

Industry benchmark playbooks and reproducible scripts for HPC system bring-up.

Current focus:
- Aerospace and Defence benchmark enablement on HPC rack systems
- Single-node validation before multi-node Slurm rollout

## Quick Start

1) Clone this repository on your benchmark node.

2) Run Phase 1 inventory and dependency validation:

```bash
bash scripts/phase1/collect_baseline.sh
bash scripts/phase1/collect_hardware_bom.sh
```

3) Run Phase 2 baselines:

```bash
bash scripts/phase2/run_stream.sh
bash scripts/phase2/run_osu.sh
bash scripts/phase2/build_hpl.sh
bash scripts/phase2/hpl_tuning_quick.sh
```

## Documentation

- Full step-by-step runbook:
  - docs/aerospace/phase1_phase2_single_node_runbook.md

- Captured results from node dmr-88:
  - docs/aerospace/results/dmr-88_phase1_phase2_results.md

- Captured hardware BOM from node dmr-88:
  - docs/aerospace/results/dmr-88_hardware_bom.md

- Model sizing matrix and shortlist:
  - docs/aerospace/results/dmr-88_model_sizing_matrix.md

- Model benchmark harness quickstart:
  - docs/aerospace/results/model_harness_quickstart.md

## Benchmark Timeline (dmr-88)

All times below are UTC.

| Phase | Benchmark | Run Time (UTC) | Artifact |
|---|---|---|---|
| Phase 1 | Baseline inventory | 2026-04-16 17:57:19 | `/root/phase1_baseline_20260416_175719.txt` |
| Phase 2 | STREAM | 2026-04-16 18:34:36 | `stream_run_20260416_183436.log` |
| Phase 2 | OSU latency | 2026-04-16 18:40:31 | `osu_latency_20260416_184031.log` |
| Phase 2 | OSU bandwidth | 2026-04-16 18:41:02 | `osu_bw_20260416_184102.log` |
| Phase 2 | HPL (prior baseline) | 2026-04-16 19:28:09 | `hpl_run_small_t1_20260416_192809.log` |
| Phase 2 | HPL sweep summary (quick) | 2026-04-16 19:48:56 | `hpl_sweep_quick_20260416_194856.csv` |
| Phase 2 | HPL sweep summary (manual) | 2026-04-16 19:54:19 | `hpl_sweep_manual_20260416_195419.csv` |

## Benchmark Durations (dmr-88)

All times below are UTC.

| Benchmark | Start | End | Elapsed (s) |
|---|---|---|---:|
| Baseline inventory | 2026-04-16 17:57:19 | 2026-04-16 17:57:20 | 1 |
| STREAM | 2026-04-16 18:34:36 | 2026-04-16 18:35:12 | 36 |
| OSU latency | 2026-04-16 18:40:31 | 2026-04-16 18:40:33 | 2 |
| OSU bandwidth | 2026-04-16 18:41:02 | 2026-04-16 18:41:04 | 2 |
| HPL prior baseline | 2026-04-16 19:28:13 | 2026-04-16 19:36:26 | 493 |
| HPL sweep quick summary | 2026-04-16 19:48:56 | 2026-04-16 19:49:39 | 43 |
| HPL sweep manual summary | 2026-04-16 19:54:19 | 2026-04-16 20:09:06 | 887 |

Duration notes:
- HPL prior baseline duration is from explicit HPL start/end lines in the log.
- Other durations are derived from artifact timestamp naming and file modified times.

## What This Repository Gives You

- Repeatable host readiness checks
- Standardized benchmark execution flow
- Practical troubleshooting notes (HPL archiver issue, oversubscription handling, STREAM memory model)
- Script-first process so a new engineer can reproduce setup on another node

## Next Planned Additions

- HPCG runbook and scripts
- Aerospace solver workload recipes (OpenFOAM, SU2)
- Slurm job templates for 1, 2, 4, and 6 node scaling
