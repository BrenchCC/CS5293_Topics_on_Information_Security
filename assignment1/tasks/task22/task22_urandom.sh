#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
SRC="${SCRIPT_DIR}/task22_urandom_keygen.c"
BIN="${OUT_DIR}/task22_urandom_keygen"

mkdir -p "${OUT_DIR}"

ENTROPY_FILE="/proc/sys/kernel/random/entropy_avail"
if [ -r "${ENTROPY_FILE}" ]; then
    BEFORE=$(cat "${ENTROPY_FILE}")
else
    BEFORE="N/A"
fi

head -c 1048576 /dev/urandom > "${OUT_DIR}/output.bin"

if [ -r "${ENTROPY_FILE}" ]; then
    AFTER=$(cat "${ENTROPY_FILE}")
else
    AFTER="N/A"
fi

ent "${OUT_DIR}/output.bin" > "${OUT_DIR}/task22_ent_output.txt"

gcc -Wall -Wextra -O2 -o "${BIN}" "${SRC}"
"${BIN}" > "${OUT_DIR}/task22_256bit_key.txt"

{
    echo "entropy_before=${BEFORE}"
    echo "entropy_after=${AFTER}"
    echo
    echo "ent output:"
    cat "${OUT_DIR}/task22_ent_output.txt"
    echo
    echo "256-bit key output:"
    cat "${OUT_DIR}/task22_256bit_key.txt"
} > "${OUT_DIR}/task22_result.txt"

cat "${OUT_DIR}/task22_result.txt"
