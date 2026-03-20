#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
TASK08_OUT="${SCRIPT_DIR}/../task08/output"

mkdir -p "${OUT_DIR}"

M="${TASK08_OUT}/out1_64.bin"
N="${TASK08_OUT}/out2_64.bin"
T="${OUT_DIR}/suffix_T.bin"

if [ ! -f "${M}" ] || [ ! -f "${N}" ]; then
  echo "Missing task08 colliding files. Run task08 first." >&2
  exit 1
fi

cat > "${T}" << 'EOT'
Task09 common suffix T\nLine2: same suffix appended to both files.\n
EOT

cat "${M}" "${T}" > "${OUT_DIR}/M_plus_T.bin"
cat "${N}" "${T}" > "${OUT_DIR}/N_plus_T.bin"

{
  echo "[Base collision]"
  md5sum "${M}"
  md5sum "${N}"
  echo
  echo "[After appending identical suffix T]"
  md5sum "${OUT_DIR}/M_plus_T.bin"
  md5sum "${OUT_DIR}/N_plus_T.bin"
} > "${OUT_DIR}/task09_md5_property.txt"

{
  echo "M_size=$(wc -c < "${M}" | tr -d ' ')"
  echo "N_size=$(wc -c < "${N}" | tr -d ' ')"
  echo "T_size=$(wc -c < "${T}" | tr -d ' ')"
  echo "M_plus_T_size=$(wc -c < "${OUT_DIR}/M_plus_T.bin" | tr -d ' ')"
  echo "N_plus_T_size=$(wc -c < "${OUT_DIR}/N_plus_T.bin" | tr -d ' ')"
} > "${OUT_DIR}/task09_sizes.txt"
