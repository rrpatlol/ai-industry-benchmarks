#!/usr/bin/env bash
set -euo pipefail

HPL_BIN_DIR="/root/benchmarks/phase2/hpl-2.3/bin/dmr-88"
SUMMARY="${HPL_BIN_DIR}/sweep_logs/hpl_sweep_quick_$(date +%Y%m%d_%H%M%S).csv"

mkdir -p "${HPL_BIN_DIR}/sweep_logs"
echo 'run_id,N,NB,P,Q,time_s,gflops,residual' > "${SUMMARY}"

bash scripts/phase2/run_hpl_case.sh q1 20000 192 8 11 "${SUMMARY}"
bash scripts/phase2/run_hpl_case.sh q2 20000 256 8 11 "${SUMMARY}"
bash scripts/phase2/run_hpl_case.sh q3 20000 384 8 11 "${SUMMARY}"
bash scripts/phase2/run_hpl_case.sh q4 20000 512 8 11 "${SUMMARY}"
bash scripts/phase2/run_hpl_case.sh q5 20000 384 4 22 "${SUMMARY}"

best=$(tail -n +2 "${SUMMARY}" | sort -t, -k7,7gr | sed -n '1p')
nb=$(echo "${best}" | cut -d, -f3)
p=$(echo "${best}" | cut -d, -f4)
q=$(echo "${best}" | cut -d, -f5)

bash scripts/phase2/run_hpl_case.sh bestL 50000 "${nb}" "${p}" "${q}" "${SUMMARY}"

echo "SUMMARY_FILE=${SUMMARY}"
echo "--- Ranked by GFLOPS ---"
{ head -n 1 "${SUMMARY}"; tail -n +2 "${SUMMARY}" | sort -t, -k7,7gr; }
