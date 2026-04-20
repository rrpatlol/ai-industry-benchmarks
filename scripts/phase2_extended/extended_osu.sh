#!/usr/bin/env bash
# Extended OSU MPI microbenchmarks: full message size sweep
# Purpose: characterize latency and bandwidth across the full spectrum of message sizes

set -e

OUT_DIR="${1:-.}"
mkdir -p "$OUT_DIR/logs"

echo "=== Extended OSU: Full message size sweep ==="

# Create a simple 2-rank nodefile
cat > /tmp/osu_nodefile.txt << 'EOF'
localhost slots=2
EOF

LOG_LAT="$OUT_DIR/logs/osu_latency_sweep_$(date +%Y%m%d_%H%M%S).log"
LOG_BW="$OUT_DIR/logs/osu_bandwidth_sweep_$(date +%Y%m%d_%H%M%S).log"

echo "OSU Latency (full sweep) -> $LOG_LAT"
mpirun -np 2 --hostfile /tmp/osu_nodefile.txt \
  /opt/osu-micro-benchmarks/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency \
  -i 100 -x 100 >> "$LOG_LAT" 2>&1

echo "OSU Bandwidth (1 B to 128 MiB) -> $LOG_BW"
mpirun -np 2 --hostfile /tmp/osu_nodefile.txt \
  /opt/osu-micro-benchmarks/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw \
  -i 100 -x 100 >> "$LOG_BW" 2>&1

echo ""
echo "Extended OSU complete. Logs in $OUT_DIR/logs/"
