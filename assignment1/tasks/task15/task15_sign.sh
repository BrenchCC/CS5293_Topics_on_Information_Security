#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK12_SCRIPT="${SCRIPT_DIR}/../task12/task12_15_rsa.sh"
OUT_DIR="${SCRIPT_DIR}/output"

mkdir -p "${OUT_DIR}"

"${TASK12_SCRIPT}"

test -f "${OUT_DIR}/task15_result.txt"
test -f "${OUT_DIR}/task15_signature_original.txt"
test -f "${OUT_DIR}/task15_signature_modified.txt"

echo "Task15 artifacts are ready in ${OUT_DIR}" 
