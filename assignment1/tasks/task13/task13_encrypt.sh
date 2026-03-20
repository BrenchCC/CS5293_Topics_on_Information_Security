#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK12_SCRIPT="${SCRIPT_DIR}/../task12/task12_15_rsa.sh"
OUT_DIR="${SCRIPT_DIR}/output"

mkdir -p "${OUT_DIR}"

"${TASK12_SCRIPT}"

test -f "${OUT_DIR}/task13_result.txt"
test -f "${OUT_DIR}/task13_message_hex.txt"
test -f "${OUT_DIR}/task13_ciphertext_hex.txt"
test -f "${OUT_DIR}/task13_decrypt_check.txt"

echo "Task13 artifacts are ready in ${OUT_DIR}" 
