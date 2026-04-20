#!/usr/bin/env bash
# Extended OSU MPI microbenchmarks: full message size sweep
# Purpose: characterize latency and bandwidth across the full spectrum of message sizes

set -e

OUT_DIR="${1:-.}"
mkdir -p "$OUT_DIR/logs"

echo "=== Extended OSU: Full message size sweep ==="

MPI_BIN="${MPI_BIN:-/usr/lib64/openmpi/bin}"
MPIRUN="$MPI_BIN/mpirun"
OSU_LAT="$MPI_BIN/osu_latency"
OSU_BW="$MPI_BIN/osu_bw"

if [[ ! -x "$MPIRUN" ]]; then
  echo "ERROR: mpirun not found at $MPIRUN"
  exit 1
fi
if [[ ! -x "$OSU_LAT" || ! -x "$OSU_BW" ]]; then
  echo "ERROR: OSU binaries not found at $MPI_BIN"
  exit 1
fi

# Create a simple 2-rank nodefile
cat > /tmp/osu_nodefile.txt << 'EOF'
localhost slots=2
EOF

LOG_LAT="$OUT_DIR/logs/osu_latency_sweep_$(date +%Y%m%d_%H%M%S).log"
LOG_BW="$OUT_DIR/logs/osu_bandwidth_sweep_$(date +%Y%m%d_%H%M%S).log"

echo "OSU Latency (full sweep) -> $LOG_LAT"
"$MPIRUN" --allow-run-as-root --mca plm_rsh_agent false -np 2 --hostfile /tmp/osu_nodefile.txt \
  "$OSU_LAT" \
  -i 100 -x 100 >> "$LOG_LAT" 2>&1

echo "OSU Bandwidth (1 B to 128 MiB) -> $LOG_BW"
"$MPIRUN" --allow-run-as-root --mca plm_rsh_agent false -np 2 --hostfile /tmp/osu_nodefile.txt \
  "$OSU_BW" \
  -i 100 -x 100 >> "$LOG_BW" 2>&1

echo ""
echo "Extended OSU complete. Logs in $OUT_DIR/logs/"
