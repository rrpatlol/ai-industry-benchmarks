#!/usr/bin/env bash
set -euo pipefail

WORKDIR="${1:-/root/benchmarks/phase2/osu}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

if [ ! -x /usr/lib64/openmpi/bin/osu_latency ] || [ ! -x /usr/lib64/openmpi/bin/osu_bw ]; then
  echo "OSU OpenMPI binaries missing. Install with: sudo dnf -y install osu-micro-benchmarks-openmpi"
  exit 1
fi

LAT_LOG="osu_latency_$(date +%Y%m%d_%H%M%S).log"
BW_LOG="osu_bw_$(date +%Y%m%d_%H%M%S).log"

/usr/lib64/openmpi/bin/mpirun --allow-run-as-root -np 2 /usr/lib64/openmpi/bin/osu_latency | tee "${LAT_LOG}"
/usr/lib64/openmpi/bin/mpirun --allow-run-as-root -np 2 /usr/lib64/openmpi/bin/osu_bw | tee "${BW_LOG}"

echo "OSU_LAT_LOG=${WORKDIR}/${LAT_LOG}"
echo "OSU_BW_LOG=${WORKDIR}/${BW_LOG}"
