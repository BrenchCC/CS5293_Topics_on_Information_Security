#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
SRC="${SCRIPT_DIR}/task18_bad_keygen.c"
BIN="${OUT_DIR}/task18_bad_keygen"

mkdir -p "${OUT_DIR}"

gcc -Wall -Wextra -O2 -o "${BIN}" "${SRC}"

{
    echo "[Run A: with srand(time(NULL))]"
    "${BIN}"
    sleep 1
    echo
    echo "[Run B: without srand line]"
    "${BIN}" --no-srand
    echo
    echo "[Run C: without srand line again]"
    "${BIN}" --no-srand
} > "${OUT_DIR}/task18_result.txt"

cat "${OUT_DIR}/task18_result.txt"
