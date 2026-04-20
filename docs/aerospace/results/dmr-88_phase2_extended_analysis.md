# Extended Phase 2 Benchmarks: dmr-88 Run Update

Date: 2026-04-20
Host: dmr-88 (88 cores, 755 GiB RAM, single NUMA)
Run directory: /root/benchmarks/phase2_extended/results_20260420_191257

## Execution Status

- STREAM extended sweep: completed
- OSU extended sweep: completed
- HPL extended sweep (N=75k,100k,125k,150k): running
  - Active log: /root/benchmarks/phase2_extended/results_20260420_191257/logs/hpl_extended_20260420_192457.log

## STREAM Results (Measured)

Triad best-rate values from logs:

| Case | Triad MB/s | Log |
|---|---:|---|
| 1 thread | 6464.5 | stream_threads_1_20260420_191257.log |
| 4 threads | 9279.1 | stream_threads_4_20260420_191350.log |
| 22 threads | 9507.7 | stream_threads_22_20260420_191427.log |
| 44 threads | 9649.5 | stream_threads_44_20260420_191504.log |
| 88 threads | 9702.1 | stream_threads_88_20260420_191541.log |
| 200M array, 88 threads | 9612.3 | stream_large_200m_20260420_191617.log |

Notes:
- Thread scaling approaches memory bandwidth saturation by 22 threads.
- 200M array run remains near peak, indicating stable streaming behavior for large working sets.

## OSU Results (Measured)

From:
- osu_latency_sweep_20260420_191724.log
- osu_bandwidth_sweep_20260420_191724.log

Key points:

| Metric | Value |
|---|---:|
| Latency @ 4 MiB | 240.01 us |
| Bandwidth @ 1 MiB | 22605.00 MB/s |
| Bandwidth @ 4 MiB | 17331.18 MB/s |
| Peak observed bandwidth | 22605.00 MB/s |

## HPL Extended Run Plan

Configuration:
- MPI ranks: 88
- Grid: P=8, Q=11
- Block sizes: NB=512, 768
- Problem sizes: N=75000, 100000, 125000, 150000
- Threading controls: OPENBLAS_NUM_THREADS=1, OMP_NUM_THREADS=1

Expected duration:
- Multi-hour run (typically 4-8 hours for full sweep on this host)

## Artifacts Produced

Current logs in /root/benchmarks/phase2_extended/results_20260420_191257/logs:
- stream_threads_1_20260420_191257.log
- stream_threads_4_20260420_191350.log
- stream_threads_22_20260420_191427.log
- stream_threads_44_20260420_191504.log
- stream_threads_88_20260420_191541.log
- stream_large_200m_20260420_191617.log
- osu_latency_sweep_20260420_191724.log
- osu_bandwidth_sweep_20260420_191724.log
- hpl_extended_20260420_192457.log (in progress)

## Next Update

After HPL completes, append:
- Per-(N,NB) GFLOPS and runtime table
- Best configuration by GFLOPS
- Residual validation status for each case
