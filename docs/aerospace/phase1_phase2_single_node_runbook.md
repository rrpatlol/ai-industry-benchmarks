# Aerospace and Defence HPC Benchmark Runbook (Phase 1 and Phase 2)

This document captures a reproducible setup and execution flow for a single CentOS Stream 10 node.

Target use case:
- Aerospace and Defence HPC platform bring-up
- Single-node validation before multi-node Slurm rollout
- Reproducible baseline collection for future 6-node rack scaling

Node used for captured results:
- Hostname: dmr-88
- OS: CentOS Stream 10
- CPU cores: 88 physical cores
- Memory: ~755 GiB

## 1) Scope and Phases

Phase 1 includes:
- Host inventory and readiness checks
- Build toolchain installation and validation
- MPI stack installation and validation
- Math library and runtime helper installation and validation

Phase 2 includes:
- STREAM memory bandwidth baseline
- MPI microbenchmarks (OSU latency and bandwidth)
- HPL build and tuning baseline

## 2) Repository Layout

- `docs/aerospace/phase1_phase2_single_node_runbook.md`: this runbook
- `docs/aerospace/results/dmr-88_phase1_phase2_results.md`: captured outputs and KPIs
- `scripts/phase1/collect_baseline.sh`: inventory script
- `scripts/phase2/run_stream.sh`: STREAM compile/run
- `scripts/phase2/run_osu.sh`: OSU latency/bw run
- `scripts/phase2/build_hpl.sh`: HPL build
- `scripts/phase2/run_hpl_case.sh`: single HPL case runner
- `scripts/phase2/hpl_tuning_quick.sh`: HPL quick sweep and ranking

## 3) Phase 1: Host Readiness and Dependency Setup

### 3.1 Collect host baseline

Run:

```bash
bash scripts/phase1/collect_baseline.sh
```

This collects:
- Host/OS/kernel
- CPU/NUMA topology
- Memory/storage
- PCI inventory (NIC/GPU/accelerators)
- Network state and link speed
- Toolchain presence
- CPU governor state

### 3.2 Install build toolchain

```bash
sudo dnf -y install gcc gcc-c++ gcc-gfortran make cmake git wget curl
```

Validation:

```bash
gcc --version | head -n 1
g++ --version | head -n 1
gfortran --version | head -n 1
make --version | head -n 1
cmake --version | head -n 1
git --version
wget --version | head -n 1
curl --version | head -n 1
```

### 3.3 Install MPI stacks

```bash
sudo dnf -y install openmpi openmpi-devel mpich mpich-devel
```

Validation:

```bash
/usr/lib64/openmpi/bin/mpirun --version
/usr/lib64/mpich/bin/mpirun --version
```

Optional MPI hello check:

```bash
cat > /tmp/mpi_hello.c << 'EOF'
#include <mpi.h>
#include <stdio.h>
int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  printf("Hello from rank %d of %d\\n", rank, size);
  MPI_Finalize();
  return 0;
}
EOF
/usr/lib64/openmpi/bin/mpicc /tmp/mpi_hello.c -o /tmp/mpi_hello_openmpi
/usr/lib64/openmpi/bin/mpirun --allow-run-as-root -np 4 /tmp/mpi_hello_openmpi | sort
```

### 3.4 Install math and helper packages

```bash
sudo dnf -y install \
  openblas openblas-devel blas-devel lapack-devel \
  hwloc hwloc-devel numactl numactl-libs \
  environment-modules python3-pip jq time
```

Validation:

```bash
numactl --hardware | sed -n '1,12p'
hwloc-info --version
python3 -m pip --version
jq --version
ldconfig -p | egrep 'libopenblas|libblas|liblapack' | head -n 12
```

## 4) Phase 2: Baseline Benchmarks

### 4.1 STREAM memory bandwidth

Run:

```bash
bash scripts/phase2/run_stream.sh
```

Key runtime settings:
- `OMP_NUM_THREADS=88`
- `OMP_PLACES=cores`
- `OMP_PROC_BIND=close`

Notes:
- For large array sizes, `-mcmodel=medium` is required to avoid relocation errors.

### 4.2 OSU MPI latency and bandwidth

Install OSU package:

```bash
sudo dnf -y install osu-micro-benchmarks-openmpi
```

Run:

```bash
bash scripts/phase2/run_osu.sh
```

### 4.3 HPL build and run

Build:

```bash
bash scripts/phase2/build_hpl.sh
```

Run one case:

```bash
bash scripts/phase2/run_hpl_case.sh CASE_ID N NB P Q
# Example:
bash scripts/phase2/run_hpl_case.sh sample 50000 512 8 11
```

Critical runtime control:
- `OPENBLAS_NUM_THREADS=1`
- `OMP_NUM_THREADS=1`

This avoids oversubscription when using many MPI ranks on a single node.

### 4.4 HPL quick tuning sweep

```bash
bash scripts/phase2/hpl_tuning_quick.sh
```

The script performs:
- Small-size tuning across NB and PxQ
- Ranking by GFLOPS
- One larger-size validation run for winning setup

## 5) Common Pitfalls and Fixes

1. HPL build error involving `r: No such file or directory`
- Cause: missing `ARCHIVER` in HPL makefile.
- Fix: set `ARCHIVER = ar` in `Make.dmr-88`.

2. HPL appears to hang or is extremely slow
- Cause: BLAS thread oversubscription with many MPI ranks.
- Fix: export `OPENBLAS_NUM_THREADS=1` and `OMP_NUM_THREADS=1`.

3. STREAM compile relocation errors on large arrays
- Cause: default memory model too small.
- Fix: add `-mcmodel=medium`.

4. Interactive shell disruptions during long run batches
- Fix: run one case at a time or use durable scripts with log files and checkpoints.

## 6) Reproducibility Rules

- Keep one benchmark process per node during runs.
- Use fixed CPU pinning and fixed thread policy.
- Keep exact build flags and package versions recorded.
- Run each benchmark at least 3 times for production-quality reporting.
- Store logs and a summary CSV per campaign.

## 7) Next Step (After This Document)

- Phase 2 continuation: HPCG baseline
- Phase 3: aerospace solver workloads (OpenFOAM and SU2)
- Phase 4: migrate exact benchmark recipes to Slurm jobs for 1, 2, 4, 6 node scaling
