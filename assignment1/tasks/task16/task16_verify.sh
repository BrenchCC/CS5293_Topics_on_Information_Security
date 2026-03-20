#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
SRC="${SCRIPT_DIR}/task16_verify_bn.c"
BIN="${OUT_DIR}/task16_verify_bn"

mkdir -p "${OUT_DIR}"

gcc -Wall -Wextra -O2 -o "${BIN}" "${SRC}" $(pkg-config --cflags --libs openssl)
"${BIN}" > "${OUT_DIR}/task16_result.txt"

grep '^Verification  = ' "${OUT_DIR}/task16_result.txt" > "${OUT_DIR}/task16_verification_summary.txt"

cat "${OUT_DIR}/task16_result.txt"
