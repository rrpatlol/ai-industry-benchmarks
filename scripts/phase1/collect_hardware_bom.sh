#!/usr/bin/env bash
set -euo pipefail

OUT_DIR=${1:-/root/benchmarks/phase1}
mkdir -p "$OUT_DIR"
STAMP=$(date -u +%Y%m%d_%H%M%S)
HOST=$(hostname -s)
OUT_FILE="$OUT_DIR/${HOST}_hardware_bom_${STAMP}.md"

first() {
  local cmd="$1"
  bash -lc "$cmd" 2>/dev/null | head -n 1
}

{
  echo "# Hardware BOM: $HOST"
  echo
  echo "- Captured: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "- Hostname: $(hostname -f 2>/dev/null || hostname)"
  echo "- OS: $(first 'source /etc/os-release && echo $PRETTY_NAME')"
  echo "- Kernel: $(uname -r)"
  echo
  echo "## Compute"
  echo
  echo "- CPU model: $(lscpu | awk -F: '/Model name/ {gsub(/^ +/,"",$2); print $2; exit}')"
  echo "- Sockets: $(lscpu | awk -F: '/Socket\(s\)/ {gsub(/^ +/,"",$2); print $2; exit}')"
  echo "- Cores per socket: $(lscpu | awk -F: '/Core\(s\) per socket/ {gsub(/^ +/,"",$2); print $2; exit}')"
  echo "- Threads per core: $(lscpu | awk -F: '/Thread\(s\) per core/ {gsub(/^ +/,"",$2); print $2; exit}')"
  echo "- Total logical CPUs: $(nproc)"
  echo "- NUMA nodes: $(lscpu | awk -F: '/NUMA node\(s\)/ {gsub(/^ +/,"",$2); print $2; exit}')"
  echo
  echo "## Memory"
  echo
  echo "- Installed memory (OS view): $(free -h | awk '/Mem:/ {print $2}')"

  if command -v dmidecode >/dev/null 2>&1; then
    local_count=$(dmidecode -t memory | awk '/Size:/ && $2 != "No" && $2 != "Not" {c++} END {print c+0}')
    echo "- Populated DIMMs found: ${local_count}"
    echo
    echo "| Locator | Size | Speed | Manufacturer | Part Number |"
    echo "|---|---|---|---|---|"
    dmidecode -t memory | awk '
      /Memory Device$/ {loc=""; size=""; speed=""; mfg=""; part=""; in=1; next}
      in && /^\tLocator:/ {sub(/^\tLocator: /, ""); loc=$0}
      in && /^\tSize:/ {sub(/^\tSize: /, ""); size=$0}
      in && /^\tSpeed:/ {sub(/^\tSpeed: /, ""); speed=$0}
      in && /^\tManufacturer:/ {sub(/^\tManufacturer: /, ""); mfg=$0}
      in && /^\tPart Number:/ {sub(/^\tPart Number: /, ""); part=$0}
      in && /^$/ {
        if (size != "" && size != "No Module Installed" && size != "Not Installed") {
          printf "| %s | %s | %s | %s | %s |\n", (loc==""?"unknown":loc), size, (speed==""?"unknown":speed), (mfg==""?"unknown":mfg), (part==""?"unknown":part)
        }
        in=0
      }
    '
  else
    echo "- Populated DIMMs found: unknown (dmidecode not available)"
  fi

  echo
  echo "## Storage Devices"
  echo
  echo "| Name | Model | Size | Rotational | Type |"
  echo "|---|---|---|---|---|"
  lsblk -d -o NAME,MODEL,SIZE,ROTA,TYPE | sed '1d' | while read -r name model size rota typ; do
    [[ -n "$name" ]] && echo "| $name | ${model:-unknown} | ${size:-unknown} | ${rota:-unknown} | ${typ:-unknown} |"
  done

  echo
  echo "## Network Interfaces"
  echo
  echo "| Interface | Speed | Duplex | Driver | MAC |"
  echo "|---|---|---|---|---|"
  ip -o link show | awk -F': ' '{print $2}' | grep -v '^lo$' | while read -r nic; do
    speed=$(ethtool "$nic" 2>/dev/null | awk -F': ' '/Speed:/ {print $2; exit}')
    duplex=$(ethtool "$nic" 2>/dev/null | awk -F': ' '/Duplex:/ {print $2; exit}')
    driver=$(ethtool -i "$nic" 2>/dev/null | awk -F': ' '/driver:/ {print $2; exit}')
    mac=$(cat "/sys/class/net/$nic/address" 2>/dev/null || true)
    echo "| $nic | ${speed:-unknown} | ${duplex:-unknown} | ${driver:-unknown} | ${mac:-unknown} |"
  done

  echo
  echo "## GPU Inventory"
  echo
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "| GPU | Memory | Driver |"
    echo "|---|---|---|"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader | while IFS=',' read -r gpu mem drv; do
      echo "| ${gpu// /} | ${mem// /} | ${drv// /} |"
    done
  else
    echo "- No NVIDIA GPUs detected via nvidia-smi."
  fi

  echo
  echo "## Platform / Firmware"
  echo
  if command -v dmidecode >/dev/null 2>&1; then
    echo "- BIOS vendor: $(dmidecode -s bios-vendor 2>/dev/null || echo unknown)"
    echo "- BIOS version: $(dmidecode -s bios-version 2>/dev/null || echo unknown)"
    echo "- Baseboard vendor: $(dmidecode -s baseboard-manufacturer 2>/dev/null || echo unknown)"
    echo "- Baseboard model: $(dmidecode -s baseboard-product-name 2>/dev/null || echo unknown)"
    echo "- Chassis type: $(dmidecode -s chassis-type 2>/dev/null || echo unknown)"
  else
    echo "- BIOS vendor: unknown"
    echo "- BIOS version: unknown"
    echo "- Baseboard vendor: unknown"
    echo "- Baseboard model: unknown"
    echo "- Chassis type: unknown"
  fi

  echo
  echo "## Notes for Fine-Tuning Planning"
  echo
  echo "- This BOM captures physical and logical node capabilities for sizing model training and fine-tuning jobs."
  echo "- For multi-node planning, pair this with interconnect topology, sustained all-reduce benchmarks, and storage throughput characterization."
} > "$OUT_FILE"

echo "Wrote hardware BOM to: $OUT_FILE"
