#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
SRC="${SCRIPT_DIR}/task11_behave_diff.c"
MD5COLLGEN="${ROOT_DIR}/tools/md5collgen"

mkdir -p "${OUT_DIR}"

if [ ! -x "${MD5COLLGEN}" ]; then
  echo "md5collgen not found: ${MD5COLLGEN}" >&2
  exit 1
fi

clang -O0 -o "${OUT_DIR}/task11_base" "${SRC}"

PATTERN_200_A="$(printf '41%.0s' $(seq 1 200))"
HEX_ALL="$(xxd -p "${OUT_DIR}/task11_base" | tr -d '\n')"
MATCHES_HEX_IDX="$(echo "${HEX_ALL}" | grep -b -o "${PATTERN_200_A}" | cut -d: -f1)"
MATCH1_HEX_IDX="$(echo "${MATCHES_HEX_IDX}" | sed -n '1p')"
MATCH2_HEX_IDX="$(echo "${MATCHES_HEX_IDX}" | sed -n '2p')"

if [ -z "${MATCH1_HEX_IDX}" ] || [ -z "${MATCH2_HEX_IDX}" ]; then
  echo "Could not locate two 200-byte 0x41 arrays in binary." >&2
  exit 1
fi

X_OFFSET=$(( MATCH1_HEX_IDX / 2 ))
Y_OFFSET=$(( MATCH2_HEX_IDX / 2 ))
REGION_LEN=128
REGION1_START="${X_OFFSET}"
REGION2_START="${Y_OFFSET}"

if [ $(( REGION1_START % 64 )) -ne 0 ]; then
  echo "Prefix length is not a multiple of 64; cannot run md5collgen with this layout." >&2
  exit 1
fi

if [ "${REGION2_START}" -le $(( REGION1_START + REGION_LEN )) ]; then
  echo "Unexpected layout: second region overlaps the first region." >&2
  exit 1
fi

PREFIX_LEN="${REGION1_START}"
MIDDLE_LEN=$(( REGION2_START - (REGION1_START + REGION_LEN) ))
SUFFIX_SKIP=$(( REGION2_START + REGION_LEN ))

head -c "${PREFIX_LEN}" "${OUT_DIR}/task11_base" > "${OUT_DIR}/prefix.bin"
dd if="${OUT_DIR}/task11_base" bs=1 skip=$(( REGION1_START + REGION_LEN )) count="${MIDDLE_LEN}" status=none > "${OUT_DIR}/middle.bin"
tail -c +$(( SUFFIX_SKIP + 1 )) "${OUT_DIR}/task11_base" > "${OUT_DIR}/suffix.bin"

"${MD5COLLGEN}" -p "${OUT_DIR}/prefix.bin" -o "${OUT_DIR}/collision1.bin" "${OUT_DIR}/collision2.bin" > "${OUT_DIR}/md5collgen_task11.log" 2>&1

tail -c 128 "${OUT_DIR}/collision1.bin" > "${OUT_DIR}/P.bin"
tail -c 128 "${OUT_DIR}/collision2.bin" > "${OUT_DIR}/Q.bin"

# Benign version: X[0:128] = P, Y[0:128] = P -> branch should be benign.
cat "${OUT_DIR}/collision1.bin" "${OUT_DIR}/middle.bin" "${OUT_DIR}/P.bin" "${OUT_DIR}/suffix.bin" > "${OUT_DIR}/task11_prog_benign"
# Malicious version: X[0:128] = Q, Y[0:128] = P -> branch should be malicious.
cat "${OUT_DIR}/collision2.bin" "${OUT_DIR}/middle.bin" "${OUT_DIR}/P.bin" "${OUT_DIR}/suffix.bin" > "${OUT_DIR}/task11_prog_malicious"
chmod +x "${OUT_DIR}/task11_prog_benign" "${OUT_DIR}/task11_prog_malicious"

{
  md5sum "${OUT_DIR}/task11_prog_benign"
  md5sum "${OUT_DIR}/task11_prog_malicious"
} > "${OUT_DIR}/task11_md5sum.txt"

"${OUT_DIR}/task11_prog_benign" > "${OUT_DIR}/task11_prog_benign_output.txt"
"${OUT_DIR}/task11_prog_malicious" > "${OUT_DIR}/task11_prog_malicious_output.txt"

# Extract first 128-byte regions used by the condition.
dd if="${OUT_DIR}/task11_prog_benign" bs=1 skip="${X_OFFSET}" count=128 of="${OUT_DIR}/benign_X128.bin" status=none
dd if="${OUT_DIR}/task11_prog_benign" bs=1 skip="${Y_OFFSET}" count=128 of="${OUT_DIR}/benign_Y128.bin" status=none
dd if="${OUT_DIR}/task11_prog_malicious" bs=1 skip="${X_OFFSET}" count=128 of="${OUT_DIR}/malicious_X128.bin" status=none
dd if="${OUT_DIR}/task11_prog_malicious" bs=1 skip="${Y_OFFSET}" count=128 of="${OUT_DIR}/malicious_Y128.bin" status=none

cmp -l "${OUT_DIR}/benign_X128.bin" "${OUT_DIR}/benign_Y128.bin" > "${OUT_DIR}/benign_XY128_diff_positions.txt" || true
cmp -l "${OUT_DIR}/malicious_X128.bin" "${OUT_DIR}/malicious_Y128.bin" > "${OUT_DIR}/malicious_XY128_diff_positions.txt" || true

xxd -g 1 "${OUT_DIR}/benign_X128.bin" > "${OUT_DIR}/benign_X128.hex"
xxd -g 1 "${OUT_DIR}/benign_Y128.bin" > "${OUT_DIR}/benign_Y128.hex"
xxd -g 1 "${OUT_DIR}/malicious_X128.bin" > "${OUT_DIR}/malicious_X128.hex"
xxd -g 1 "${OUT_DIR}/malicious_Y128.bin" > "${OUT_DIR}/malicious_Y128.hex"

{
  echo "x_offset=${X_OFFSET}"
  echo "y_offset=${Y_OFFSET}"
  echo "region1_start=${REGION1_START}"
  echo "region2_start=${REGION2_START}"
  echo "region_len=${REGION_LEN}"
  echo "prefix_len=${PREFIX_LEN}"
  echo "prefix_len_mod_64=$(( PREFIX_LEN % 64 ))"
  echo "middle_len=${MIDDLE_LEN}"
  echo "suffix_skip=${SUFFIX_SKIP}"
  echo "base_size=$(wc -c < "${OUT_DIR}/task11_base" | tr -d ' ')"
  echo "benign_size=$(wc -c < "${OUT_DIR}/task11_prog_benign" | tr -d ' ')"
  echo "malicious_size=$(wc -c < "${OUT_DIR}/task11_prog_malicious" | tr -d ' ')"
} > "${OUT_DIR}/task11_offsets.txt"
