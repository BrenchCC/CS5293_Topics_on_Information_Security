#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${BASE_DIR}/output"
INPUT_FILE="${BASE_DIR}/../../assignment1-supplymentary/words.txt"

KEY_HEX="00112233445566778899aabbccddeeff"
IV_HEX="0102030405060708090a0b0c0d0e0f10"

CIPHERS=(
  "-aes-128-cbc"
  "-aes-128-cfb"
  "-aes-128-ofb"
)

mkdir -p "${OUTPUT_DIR}"
: > "${OUTPUT_DIR}/verification_sha256.txt"
: > "${OUTPUT_DIR}/verification_diff.txt"

for cipher in "${CIPHERS[@]}"; do
  cipher_name="${cipher#-}"
  enc_file="${OUTPUT_DIR}/words_${cipher_name}.enc"
  dec_file="${OUTPUT_DIR}/words_${cipher_name}.dec.txt"

  openssl enc "${cipher}" -e \
    -in "${INPUT_FILE}" \
    -out "${enc_file}" \
    -K "${KEY_HEX}" \
    -iv "${IV_HEX}"

  openssl enc "${cipher}" -d \
    -in "${enc_file}" \
    -out "${dec_file}" \
    -K "${KEY_HEX}" \
    -iv "${IV_HEX}"

  {
    echo "=== ${cipher} ==="
    sha256sum "${INPUT_FILE}" "${dec_file}"
    echo
  } >> "${OUTPUT_DIR}/verification_sha256.txt"

  {
    echo "=== ${cipher} ==="
    if diff -u "${INPUT_FILE}" "${dec_file}" > /dev/null; then
      echo "diff result: identical"
    else
      echo "diff result: mismatch"
      diff -u "${INPUT_FILE}" "${dec_file}"
    fi
    echo
  } >> "${OUTPUT_DIR}/verification_diff.txt"
done

{
  echo "Cipher list used in this task:"
  for cipher in "${CIPHERS[@]}"; do
    echo "- ${cipher}"
  done
} > "${OUTPUT_DIR}/cipher_list.txt"
