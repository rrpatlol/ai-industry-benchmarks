# dmr-88 Phase 1 and Phase 2 Results Summary

Date: 2026-04-16
Host: dmr-88

## Phase 1 Summary

Node facts:
- OS: CentOS Stream 10
- Kernel: 6.18.0-dmr.bkc.6.18.3.8.3.x86_64
- CPU: 88 cores, single NUMA node
- Memory: ~755 GiB
- Network: ens12 1000 Mb/s

Validated toolchain:
- gcc 14.3.1
- g++ 14.3.1
- gfortran 14.3.1
- make 4.4.1
- cmake 3.31.8
- git 2.52.0
- wget 1.24.5
- curl 8.12.1

Validated MPI:
- Open MPI 5.0.2
- MPICH 4.1.2
- MPI hello world verified with both implementations.

Math/helper stack:
- OpenBLAS and BLAS/LAPACK development libraries installed
- numactl/hwloc installed
- jq and pip installed

## Phase 2 Summary

### STREAM (88 OpenMP threads)

Best rates:
- Copy: 9409.5 MB/s
- Scale: 9026.5 MB/s
- Add: 9786.2 MB/s
- Triad: 9760.3 MB/s

Validation: solution validates.

### OSU MPI microbenchmarks (OpenMPI, 2 ranks)

Latency sample:
- 4 MiB message: 236.75 us

Bandwidth sample:
- 1 MiB message: 22618.43 MB/s
- Peak observed region: ~22.6 GB/s

### HPL

Single case (prior baseline):
- N=50000, NB=384, P=8, Q=11
- Time: 493.06 s
- GFLOPS: 169.02
- Residual: PASSED

Quick tuning sweep:
- q1: N=20000 NB=192 P=8 Q=11 -> 136.02 GFLOPS (PASSED)
- q2: N=20000 NB=256 P=8 Q=11 -> 149.17 GFLOPS (PASSED)
- q3: N=20000 NB=384 P=8 Q=11 -> 154.58 GFLOPS (PASSED)
- q4: N=20000 NB=512 P=8 Q=11 -> 160.15 GFLOPS (PASSED)
- q5: N=20000 NB=384 P=4 Q=22 -> 156.75 GFLOPS (PASSED)

Best large-N validation:
- bestL: N=50000 NB=512 P=8 Q=11
- Time: 476.82 s
- GFLOPS: 174.78
- Residual: PASSED

## Recommended Single-Node HPL Profile

- MPI ranks: 88
- Process grid: P=8, Q=11
- NB: 512
- OPENBLAS_NUM_THREADS=1
- OMP_NUM_THREADS=1

## Artifact Paths on Node

- Baseline inventory report:
  - /root/phase1_baseline_20260416_175719.txt
- STREAM logs:
  - /root/benchmarks/phase2/stream/stream_run_*.log
- OSU logs:
  - /root/benchmarks/phase2/osu/osu_latency_*.log
  - /root/benchmarks/phase2/osu/osu_bw_*.log
- HPL logs and summaries:
  - /root/benchmarks/phase2/hpl-2.3/bin/dmr-88/hpl_run_*.log
  - /root/benchmarks/phase2/hpl-2.3/bin/dmr-88/sweep_logs/*.csv
