#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 5 ]; then
  echo "Usage: $0 CASE_ID N NB P Q [SUMMARY_CSV]"
  exit 1
fi

CASE_ID="$1"
N="$2"
NB="$3"
P="$4"
Q="$5"
SUMMARY_CSV="${6:-}"

HPL_BIN_DIR="/root/benchmarks/phase2/hpl-2.3/bin/dmr-88"
cd "${HPL_BIN_DIR}"
mkdir -p sweep_logs

cat > HPL.dat <<EOF
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
${N}        Ns
1            # of NBs
${NB}          NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
${P}            Ps
${Q}           Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
2            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=L,5=Lng,6=I,7=LnM,8=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOF

LOG="sweep_logs/${CASE_ID}_N${N}_NB${NB}_P${P}Q${Q}.log"
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 \
/usr/lib64/openmpi/bin/mpirun --allow-run-as-root --bind-to core --map-by core \
  -x OPENBLAS_NUM_THREADS -x OMP_NUM_THREADS -np 88 ./xhpl > "${LOG}" 2>&1

line=$(grep '^WR' "${LOG}" | tail -n 1 || true)
time_s=$(echo "${line}" | awk '{print $(NF-1)}')
gflops=$(echo "${line}" | awk '{print $NF}')
resid=$(grep -E 'PASSED|FAILED' "${LOG}" | tail -n 1 | awk '{print $NF}')

echo "CASE=${CASE_ID} N=${N} NB=${NB} P=${P} Q=${Q} time=${time_s:-NA} gflops=${gflops:-NA} residual=${resid:-UNKNOWN}"
echo "LOG=${HPL_BIN_DIR}/${LOG}"

if [ -n "${SUMMARY_CSV}" ]; then
  if [ ! -f "${SUMMARY_CSV}" ]; then
    echo 'run_id,N,NB,P,Q,time_s,gflops,residual' > "${SUMMARY_CSV}"
  fi
  printf '%s,%s,%s,%s,%s,%s,%s,%s\n' "${CASE_ID}" "${N}" "${NB}" "${P}" "${Q}" "${time_s:-NA}" "${gflops:-NA}" "${resid:-UNKNOWN}" >> "${SUMMARY_CSV}"
  echo "SUMMARY_UPDATED=${SUMMARY_CSV}"
fi
