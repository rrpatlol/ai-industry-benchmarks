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

## What This Repository Gives You

- Repeatable host readiness checks
- Standardized benchmark execution flow
- Practical troubleshooting notes (HPL archiver issue, oversubscription handling, STREAM memory model)
- Script-first process so a new engineer can reproduce setup on another node

## Next Planned Additions

- HPCG runbook and scripts
- Aerospace solver workload recipes (OpenFOAM, SU2)
- Slurm job templates for 1, 2, 4, and 6 node scaling
