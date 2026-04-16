#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-/root}"
REPORT="${OUT_DIR}/phase1_baseline_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "===== Phase 1 Baseline ====="
  date
  echo
  echo "## Host/OS"
  hostname
  cat /etc/os-release || true
  uname -a

  echo
  echo "## CPU/NUMA"
  lscpu || true
  numactl --hardware || true
  nproc || true

  echo
  echo "## Memory/Storage"
  free -h || true
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL || true
  df -h || true

  echo
  echo "## PCI (GPU/NIC/Accel)"
  lspci | egrep -i "vga|3d|nvidia|amd|ethernet|infiniband|mlx|broadcom|intel" || true

  echo
  echo "## Network"
  ip -br addr || true
  ip -br link || true
  for i in $(ls /sys/class/net | egrep -v "lo"); do
    echo "=== ${i} ==="
    ethtool "${i}" 2>/dev/null | egrep -i "speed|duplex|link detected" || true
  done

  echo
  echo "## Toolchain"
  gcc --version 2>/dev/null | head -n 1 || echo "gcc: missing"
  g++ --version 2>/dev/null | head -n 1 || echo "g++: missing"
  clang --version 2>/dev/null | head -n 1 || echo "clang: missing"
  mpicc --version 2>/dev/null | head -n 1 || echo "mpicc: missing"
  mpirun --version 2>/dev/null | head -n 2 || echo "mpirun: missing"
  cmake --version 2>/dev/null | head -n 1 || echo "cmake: missing"
  python3 --version 2>/dev/null || echo "python3: missing"

  echo
  echo "## CPU Power Policy"
  cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "cpufreq governor info unavailable"
  cat /sys/devices/system/cpu/intel_pstate/status 2>/dev/null || true
} | tee "${REPORT}"

echo "REPORT_PATH=${REPORT}"
