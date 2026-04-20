#!/usr/bin/env bash
# Extended HPL: larger aerospace-scale problem sizes (N up to 150k)
# Purpose: characterize compute performance and memory usage for realistic workloads

set -e

OUT_DIR="${1:-.}"
OUT_DIR_ABS="$(readlink -f "$OUT_DIR")"
mkdir -p "$OUT_DIR/logs" "$OUT_DIR/hpl_inputs"

cd /root/benchmarks/phase2/hpl-2.3
mkdir -p hpl_inputs

echo "=== Extended HPL: Aerospace-scale problem sizes ==="

# Input file with N from 75k to 150k
cat > hpl_inputs/HPL_extended.dat << 'EOF'
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
4            # of problems sizes (N)
75000 100000 125000 150000   Ns
2            # of NBs
512 768      NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
8 Q
11 Q
16.0         threshold
1            # of panel factorization
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterions
4            NBMINs (>= 1)
1            # of recursion depths
2            NDIVs
3            # of recursive panel facts.
1            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rM,1=1rMW,...)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOF

export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
MPI_BIN="${MPI_BIN:-/usr/lib64/openmpi/bin}"
MPIRUN="$MPI_BIN/mpirun"

if [[ ! -x "$MPIRUN" ]]; then
  echo "ERROR: mpirun not found at $MPIRUN"
  exit 1
fi

LOG="$OUT_DIR_ABS/logs/hpl_extended_$(date +%Y%m%d_%H%M%S).log"

# Ensure xhpl finds its default input file in current working directory.
cp hpl_inputs/HPL_extended.dat HPL.dat

echo "Running HPL extended sweep: N=75k,100k,125k,150k -> $LOG"
echo "This may take 4-8 hours depending on system load."
echo ""

"$MPIRUN" --allow-run-as-root --mca plm_rsh_agent false -np 88 \
  --map-by ppr:88:node \
  --bind-to core \
  /root/benchmarks/phase2/hpl-2.3/bin/dmr-88/xhpl 2>&1 | tee "$LOG"

echo ""
echo "Extended HPL complete. Results in $LOG"
