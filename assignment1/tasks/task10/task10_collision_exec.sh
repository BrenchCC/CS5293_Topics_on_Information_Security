#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
SRC="${SCRIPT_DIR}/task10_collision_exec.c"
MD5COLLGEN="${ROOT_DIR}/tools/md5collgen"

mkdir -p "${OUT_DIR}"

if [ ! -x "${MD5COLLGEN}" ]; then
  echo "md5collgen not found: ${MD5COLLGEN}" >&2
  exit 1
fi

clang -O0 -o "${OUT_DIR}/task10_base" "${SRC}"

# Locate the first run of 200 bytes of 0x41 from the binary (hex-stream search).
PATTERN_200_A="$(printf '41%.0s' $(seq 1 200))"
HEX_ALL="$(xxd -p "${OUT_DIR}/task10_base" | tr -d '\n')"
MATCH_IDX="$(echo "${HEX_ALL}" | grep -b -o "${PATTERN_200_A}" | head -1 | cut -d: -f1)"

if [ -z "${MATCH_IDX}" ]; then
  echo "Could not find 200-byte xyz array in binary." >&2
  exit 1
fi

ARRAY_OFFSET=$(( MATCH_IDX / 2 ))
SHIFT=$(( (64 - (ARRAY_OFFSET % 64)) % 64 ))
REGION_START=$(( ARRAY_OFFSET + SHIFT ))
REGION_LEN=128
REGION_END=$(( REGION_START + REGION_LEN - 1 ))

if [ "${SHIFT}" -gt 72 ]; then
  echo "Computed shift (${SHIFT}) exceeds allowable range inside 200-byte array." >&2
  exit 1
fi

PREFIX_LEN="${REGION_START}"
SUFFIX_START_1BASED=$(( REGION_START + REGION_LEN + 1 ))

head -c "${PREFIX_LEN}" "${OUT_DIR}/task10_base" > "${OUT_DIR}/prefix.bin"
tail -c +"${SUFFIX_START_1BASED}" "${OUT_DIR}/task10_base" > "${OUT_DIR}/suffix.bin"

"${MD5COLLGEN}" -p "${OUT_DIR}/prefix.bin" -o "${OUT_DIR}/collision1.bin" "${OUT_DIR}/collision2.bin" > "${OUT_DIR}/md5collgen_task10.log" 2>&1

cat "${OUT_DIR}/collision1.bin" "${OUT_DIR}/suffix.bin" > "${OUT_DIR}/task10_prog1"
cat "${OUT_DIR}/collision2.bin" "${OUT_DIR}/suffix.bin" > "${OUT_DIR}/task10_prog2"
chmod +x "${OUT_DIR}/task10_prog1" "${OUT_DIR}/task10_prog2"

{
  md5sum "${OUT_DIR}/task10_prog1"
  md5sum "${OUT_DIR}/task10_prog2"
} > "${OUT_DIR}/task10_md5sum.txt"

"${OUT_DIR}/task10_prog1" > "${OUT_DIR}/task10_prog1_output.txt"
"${OUT_DIR}/task10_prog2" > "${OUT_DIR}/task10_prog2_output.txt"

cmp -l "${OUT_DIR}/task10_prog1" "${OUT_DIR}/task10_prog2" > "${OUT_DIR}/task10_binary_diff_positions.txt" || true

# Capture the 200-byte xyz segment from each program for direct evidence.
dd if="${OUT_DIR}/task10_prog1" bs=1 skip="${ARRAY_OFFSET}" count=200 of="${OUT_DIR}/task10_prog1_xyz.bin" status=none
dd if="${OUT_DIR}/task10_prog2" bs=1 skip="${ARRAY_OFFSET}" count=200 of="${OUT_DIR}/task10_prog2_xyz.bin" status=none
xxd -g 1 "${OUT_DIR}/task10_prog1_xyz.bin" > "${OUT_DIR}/task10_prog1_xyz.hex"
xxd -g 1 "${OUT_DIR}/task10_prog2_xyz.bin" > "${OUT_DIR}/task10_prog2_xyz.hex"
cmp -l "${OUT_DIR}/task10_prog1_xyz.bin" "${OUT_DIR}/task10_prog2_xyz.bin" > "${OUT_DIR}/task10_xyz_diff_positions.txt" || true

{
  echo "array_offset=${ARRAY_OFFSET}"
  echo "shift_within_array=${SHIFT}"
  echo "region_start=${REGION_START}"
  echo "region_end=${REGION_END}"
  echo "region_len=${REGION_LEN}"
  echo "prefix_len=${PREFIX_LEN}"
  echo "prefix_len_mod_64=$(( PREFIX_LEN % 64 ))"
  echo "suffix_start_1based=${SUFFIX_START_1BASED}"
  echo "base_size=$(wc -c < "${OUT_DIR}/task10_base" | tr -d ' ')"
  echo "prog1_size=$(wc -c < "${OUT_DIR}/task10_prog1" | tr -d ' ')"
  echo "prog2_size=$(wc -c < "${OUT_DIR}/task10_prog2" | tr -d ' ')"
} > "${OUT_DIR}/task10_offsets.txt"
