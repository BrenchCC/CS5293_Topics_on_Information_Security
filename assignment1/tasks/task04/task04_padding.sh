#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${BASE_DIR}/output"
KEY_HEX="00112233445566778899aabbccddeeff"
IV_HEX="0102030405060708090a0b0c0d0e0f10"

mkdir -p "${OUT_DIR}"

# Part A: mode vs padding behavior using a non-multiple-of-16 plaintext
printf "123456789012345678901" > "${OUT_DIR}/mode_input_21.txt"  # 21 bytes

for mode in ecb cbc cfb ofb; do
  in_file="${OUT_DIR}/mode_input_21.txt"
  out_file="${OUT_DIR}/mode_${mode}.bin"

  if [[ "${mode}" == "ecb" ]]; then
    openssl enc -aes-128-ecb -e -nosalt -in "${in_file}" -out "${out_file}" -K "${KEY_HEX}"
  else
    openssl enc -aes-128-${mode} -e -nosalt -in "${in_file}" -out "${out_file}" -K "${KEY_HEX}" -iv "${IV_HEX}"
  fi
done

{
  echo "Mode padding size check (input length = $(wc -c < "${OUT_DIR}/mode_input_21.txt") bytes):"
  for mode in ecb cbc cfb ofb; do
    echo "${mode}: $(wc -c < "${OUT_DIR}/mode_${mode}.bin") bytes"
  done
} > "${OUT_DIR}/mode_padding_sizes.txt"

# Part B: 5/10/16-byte files with AES-128-CBC
printf "12345" > "${OUT_DIR}/f5.txt"
printf "1234567890" > "${OUT_DIR}/f10.txt"
printf "1234567890abcdef" > "${OUT_DIR}/f16.txt"

for n in 5 10 16; do
  openssl enc -aes-128-cbc -e -nosalt \
    -in "${OUT_DIR}/f${n}.txt" \
    -out "${OUT_DIR}/f${n}.cbc.enc" \
    -K "${KEY_HEX}" \
    -iv "${IV_HEX}"

  # Keep padding bytes by disabling unpadding during decryption.
  openssl enc -aes-128-cbc -d -nosalt -nopad \
    -in "${OUT_DIR}/f${n}.cbc.enc" \
    -out "${OUT_DIR}/f${n}.cbc.dec.nopad.bin" \
    -K "${KEY_HEX}" \
    -iv "${IV_HEX}"

done

{
  echo "CBC encrypted file sizes:"
  for n in 5 10 16; do
    echo "f${n}.cbc.enc: $(wc -c < "${OUT_DIR}/f${n}.cbc.enc") bytes"
  done
} > "${OUT_DIR}/cbc_file_sizes.txt"

{
  echo "Last block hex (from decrypted -nopad output):"
  for n in 5 10 16; do
    last_block_hex="$(xxd -p -c 16 "${OUT_DIR}/f${n}.cbc.dec.nopad.bin" | tail -n 1)"
    echo "f${n}: ${last_block_hex}"
  done
} > "${OUT_DIR}/padding_last_block_hex.txt"
