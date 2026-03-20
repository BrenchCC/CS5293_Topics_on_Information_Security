#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${BASE_DIR}/output"
SHOT_DIR="${BASE_DIR}/screenshots"
SRC_DIR="${BASE_DIR}/../../assignment1-supplymentary"

PROVIDED_BMP="${SRC_DIR}/pic_original.bmp"
OWN_BMP="${OUTPUT_DIR}/own_picture.bmp"

KEY_HEX="00112233445566778899aabbccddeeff"
IV_HEX="0102030405060708090a0b0c0d0e0f10"

mkdir -p "${OUTPUT_DIR}" "${SHOT_DIR}"

# Build a personal picture by resizing and rotating the provided image.
sips -z 256 256 "${PROVIDED_BMP}" --out "${OUTPUT_DIR}/own_picture_tmp.bmp" >/dev/null
sips -r 180 "${OUTPUT_DIR}/own_picture_tmp.bmp" --out "${OWN_BMP}" >/dev/null
rm -f "${OUTPUT_DIR}/own_picture_tmp.bmp"

process_bmp() {
  local input_bmp="$1"
  local tag="$2"

  local header_file="${OUTPUT_DIR}/${tag}_header.bin"
  local body_file="${OUTPUT_DIR}/${tag}_body.bin"
  local ecb_body="${OUTPUT_DIR}/${tag}_body_ecb.bin"
  local cbc_body="${OUTPUT_DIR}/${tag}_body_cbc.bin"
  local ecb_bmp="${OUTPUT_DIR}/${tag}_ecb.bmp"
  local cbc_bmp="${OUTPUT_DIR}/${tag}_cbc.bmp"

  dd if="${input_bmp}" of="${header_file}" bs=1 count=54 status=none
  dd if="${input_bmp}" of="${body_file}" bs=1 skip=54 status=none

  # Encrypt only pixel data so the BMP header remains viewable by image tools.
  openssl enc -aes-128-ecb -e -nosalt \
    -in "${body_file}" \
    -out "${ecb_body}" \
    -K "${KEY_HEX}"

  openssl enc -aes-128-cbc -e -nosalt \
    -in "${body_file}" \
    -out "${cbc_body}" \
    -K "${KEY_HEX}" \
    -iv "${IV_HEX}"

  cat "${header_file}" "${ecb_body}" > "${ecb_bmp}"
  cat "${header_file}" "${cbc_body}" > "${cbc_bmp}"

  # Export PNG previews as screenshot evidence files.
  sips -s format png "${input_bmp}" --out "${SHOT_DIR}/${tag}_original.png" >/dev/null
  sips -s format png "${ecb_bmp}" --out "${SHOT_DIR}/${tag}_ecb.png" >/dev/null
  sips -s format png "${cbc_bmp}" --out "${SHOT_DIR}/${tag}_cbc.png" >/dev/null
}

process_bmp "${PROVIDED_BMP}" "provided"
process_bmp "${OWN_BMP}" "own"

{
  echo "Task 03 ciphers/modes used:"
  echo "-aes-128-ecb"
  echo "-aes-128-cbc"
  echo
  echo "Input and output file sizes (bytes):"
  wc -c "${PROVIDED_BMP}" "${OUTPUT_DIR}/provided_ecb.bmp" "${OUTPUT_DIR}/provided_cbc.bmp"
  wc -c "${OWN_BMP}" "${OUTPUT_DIR}/own_ecb.bmp" "${OUTPUT_DIR}/own_cbc.bmp"
} > "${OUTPUT_DIR}/task03_summary.txt"
