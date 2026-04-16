#!/usr/bin/env bash
set -euo pipefail

WORKDIR="${1:-/root/benchmarks/phase2/stream}"
THREADS="${2:-88}"
ARRAY_SIZE="${3:-200000000}"
NTIMES="${4:-20}"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

if [ ! -f stream.c ]; then
  curl -fsSL https://www.cs.virginia.edu/stream/FTP/Code/stream.c -o stream.c
fi

gcc -O3 -fopenmp -march=native -mcmodel=medium -DSTREAM_ARRAY_SIZE=${ARRAY_SIZE} -DNTIMES=${NTIMES} stream.c -o stream_omp

export OMP_NUM_THREADS="${THREADS}"
export OMP_PLACES=cores
export OMP_PROC_BIND=close

LOG="stream_run_$(date +%Y%m%d_%H%M%S).log"
./stream_omp | tee "${LOG}"
echo "STREAM_LOG=${WORKDIR}/${LOG}"
