#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
SRC="${SCRIPT_DIR}/task19_guess_key.c"
BIN="${OUT_DIR}/task19_guess_key"

mkdir -p "${OUT_DIR}"

gcc -Wall -Wextra -O2 -o "${BIN}" "${SRC}" $(pkg-config --cflags --libs openssl)

END=$(date -j -f "%Y-%m-%d %H:%M:%S" "2018-04-17 23:08:49" "+%s")
START=$((END - 7200))

{
    echo "search_start_epoch=${START}"
    echo "search_end_epoch=${END}"
    echo
    "${BIN}" "${START}" "${END}"
    echo
    echo "[Reference verification]"
    echo "reference_key_hex=95fa2030e73ed3f8da761b4eb805dfd7"
    printf 'd06bf9d0dab8e8ef880660d2af65aa82' | xxd -r -p > "${OUT_DIR}/task19_ct_block.bin"
    openssl enc -aes-128-cbc -d -nopad \
        -K 95fa2030e73ed3f8da761b4eb805dfd7 \
        -iv 09080706050403020100A2B2C2D2E2F2 \
        -in "${OUT_DIR}/task19_ct_block.bin" \
        | xxd -p -c 1000
} > "${OUT_DIR}/task19_result.txt"

cat "${OUT_DIR}/task19_result.txt"
