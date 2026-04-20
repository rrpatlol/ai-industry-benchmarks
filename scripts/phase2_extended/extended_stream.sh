#!/usr/bin/env bash
# Extended STREAM benchmark: variable thread counts and array sizes
# Purpose: characterize memory bandwidth under different load and working-set configurations

set -e

OUT_DIR="${1:-.}"
mkdir -p "$OUT_DIR/logs"

echo "=== Extended STREAM: Threading sweep ==="

# Threading sweep: 1, 4, 22, 44, 88 threads
for THREADS in 1 4 22 44 88; do
  LOG="$OUT_DIR/logs/stream_threads_${THREADS}_$(date +%Y%m%d_%H%M%S).log"
  echo "Running STREAM with $THREADS threads -> $LOG"
  OMP_NUM_THREADS=$THREADS OMP_NUM_TEAMS=1 /root/benchmarks/phase2/stream/stream_omp >> "$LOG" 2>&1
  echo "  Complete."
done

echo ""
echo "=== Extended STREAM: Large array size (200M elements) ==="

LOG="$OUT_DIR/logs/stream_large_200m_$(date +%Y%m%d_%H%M%S).log"
echo "Compiling and running with 200M array size -> $LOG"

gcc -O3 -mcmodel=medium -fopenmp \
  -DSTREAM_ARRAY_SIZE=200000000 \
  -DSTREAM_TYPE=double \
  /root/benchmarks/phase2/stream/stream.c -o /tmp/stream_large 2>&1 | tee -a "$LOG"

OMP_NUM_THREADS=88 /tmp/stream_large >> "$LOG" 2>&1

echo ""
echo "Extended STREAM complete. Logs in $OUT_DIR/logs/"
