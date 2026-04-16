#!/usr/bin/env bash
set -euo pipefail

HPL_ROOT="${1:-/root/benchmarks/phase2}"
HPL_VER="2.3"
HPL_DIR="${HPL_ROOT}/hpl-${HPL_VER}"

mkdir -p "${HPL_ROOT}"
cd "${HPL_ROOT}"

if [ ! -f "hpl-${HPL_VER}.tar.gz" ]; then
  curl -fsSLO "https://www.netlib.org/benchmark/hpl/hpl-${HPL_VER}.tar.gz"
fi
if [ ! -d "hpl-${HPL_VER}" ]; then
  tar -xzf "hpl-${HPL_VER}.tar.gz"
fi

cd "${HPL_DIR}"
cp -f setup/Make.Linux_PII_CBLAS Make.dmr-88
sed -i 's/^ARCH.*/ARCH         = dmr-88/' Make.dmr-88
sed -i "s#^TOPdir.*#TOPdir       = ${HPL_DIR}#" Make.dmr-88
sed -i 's#^MPdir.*#MPdir        = /usr/lib64/openmpi#' Make.dmr-88
sed -i 's#^MPlib.*#MPlib        = $(MPdir)/lib/libmpi.so#' Make.dmr-88
sed -i 's#^LAdir.*#LAdir        = /usr/lib64#' Make.dmr-88
sed -i 's#^LAlib.*#LAlib        = -lopenblas#' Make.dmr-88
sed -i 's#^CC[[:space:]]*=.*#CC           = /usr/lib64/openmpi/bin/mpicc#' Make.dmr-88
sed -i 's#^LINKER[[:space:]]*=.*#LINKER       = /usr/lib64/openmpi/bin/mpicc#' Make.dmr-88
if ! grep -q '^ARCHIVER' Make.dmr-88; then
  sed -i '/^ARFLAGS/i ARCHIVER     = ar' Make.dmr-88
fi

make arch=dmr-88 -j 16

echo "XHPL_PATH=${HPL_DIR}/bin/dmr-88/xhpl"
