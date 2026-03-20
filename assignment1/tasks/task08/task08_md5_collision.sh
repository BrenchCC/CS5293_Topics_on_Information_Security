#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
MD5COLLGEN="${ROOT_DIR}/tools/md5collgen"

mkdir -p "${OUT_DIR}"

if [ ! -x "${MD5COLLGEN}" ]; then
  echo "md5collgen not found: ${MD5COLLGEN}" >&2
  exit 1
fi

PREFIX_NON64="${OUT_DIR}/prefix_non64.txt"
PREFIX_64="${OUT_DIR}/prefix_64.txt"

printf 'Task08-prefix-not-64-bytes.' > "${PREFIX_NON64}"
printf 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' > "${PREFIX_64}"

NON64_LEN="$(wc -c < "${PREFIX_NON64}" | tr -d ' ')"
LEN64="$(wc -c < "${PREFIX_64}" | tr -d ' ')"

"${MD5COLLGEN}" -p "${PREFIX_NON64}" -o "${OUT_DIR}/out1_non64.bin" "${OUT_DIR}/out2_non64.bin" > "${OUT_DIR}/md5collgen_non64.log" 2>&1
"${MD5COLLGEN}" -p "${PREFIX_64}" -o "${OUT_DIR}/out1_64.bin" "${OUT_DIR}/out2_64.bin" > "${OUT_DIR}/md5collgen_64.log" 2>&1

{
  echo "[non64]"
  diff "${OUT_DIR}/out1_non64.bin" "${OUT_DIR}/out2_non64.bin" || true
  md5sum "${OUT_DIR}/out1_non64.bin"
  md5sum "${OUT_DIR}/out2_non64.bin"
  echo
  echo "[len64]"
  diff "${OUT_DIR}/out1_64.bin" "${OUT_DIR}/out2_64.bin" || true
  md5sum "${OUT_DIR}/out1_64.bin"
  md5sum "${OUT_DIR}/out2_64.bin"
} > "${OUT_DIR}/task08_diff_md5.txt"

# Extract the 128-byte collision blocks after the 64-byte prefix.
dd if="${OUT_DIR}/out1_64.bin" bs=1 skip="${LEN64}" count=128 of="${OUT_DIR}/block1_64.bin" status=none
dd if="${OUT_DIR}/out2_64.bin" bs=1 skip="${LEN64}" count=128 of="${OUT_DIR}/block2_64.bin" status=none

cmp -l "${OUT_DIR}/block1_64.bin" "${OUT_DIR}/block2_64.bin" > "${OUT_DIR}/collision_block_diff_positions.txt" || true
xxd -g 1 "${OUT_DIR}/block1_64.bin" > "${OUT_DIR}/block1_64.hex"
xxd -g 1 "${OUT_DIR}/block2_64.bin" > "${OUT_DIR}/block2_64.hex"

{
  echo "non64_prefix_len=${NON64_LEN}"
  echo "len64_prefix_len=${LEN64}"
  echo "out1_non64_size=$(wc -c < "${OUT_DIR}/out1_non64.bin" | tr -d ' ')"
  echo "out2_non64_size=$(wc -c < "${OUT_DIR}/out2_non64.bin" | tr -d ' ')"
  echo "out1_64_size=$(wc -c < "${OUT_DIR}/out1_64.bin" | tr -d ' ')"
  echo "out2_64_size=$(wc -c < "${OUT_DIR}/out2_64.bin" | tr -d ' ')"
} > "${OUT_DIR}/task08_sizes.txt"
