#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT12="${SCRIPT_DIR}/output"
OUT13="${SCRIPT_DIR}/../task13/output"
OUT14="${SCRIPT_DIR}/../task14/output"
OUT15="${SCRIPT_DIR}/../task15/output"
SRC="${SCRIPT_DIR}/task12_15_rsa_bn.c"
BIN="${OUT12}/task12_15_rsa_bn"

mkdir -p "${OUT12}" "${OUT13}" "${OUT14}" "${OUT15}"

gcc -Wall -Wextra -O2 -o "${BIN}" "${SRC}" $(pkg-config --cflags --libs openssl)
"${BIN}" > "${OUT12}/task12_15_results.txt"

awk '/^\[Task12\]/{flag=1} /^\[Task13\]/{flag=0} flag {print}' "${OUT12}/task12_15_results.txt" > "${OUT12}/task12_result.txt"
awk '/^\[Task13\]/{flag=1} /^\[Task14\]/{flag=0} flag {print}' "${OUT12}/task12_15_results.txt" > "${OUT13}/task13_result.txt"
awk '/^\[Task14\]/{flag=1} /^\[Task15\]/{flag=0} flag {print}' "${OUT12}/task12_15_results.txt" > "${OUT14}/task14_result.txt"
awk '/^\[Task15\]/{flag=1} flag {print}' "${OUT12}/task12_15_results.txt" > "${OUT15}/task15_result.txt"

# Useful extracted evidence files.
grep '^d = ' "${OUT12}/task12_result.txt" > "${OUT12}/task12_private_key.txt"
grep '^phi(n) = ' "${OUT12}/task12_result.txt" > "${OUT12}/task12_phi.txt"
grep -F '(e*d) mod phi(n) = ' "${OUT12}/task12_result.txt" > "${OUT12}/task12_check.txt"

grep '^M hex = ' "${OUT13}/task13_result.txt" > "${OUT13}/task13_message_hex.txt"
grep '^C hex = ' "${OUT13}/task13_result.txt" > "${OUT13}/task13_ciphertext_hex.txt"
grep '^Decrypted ASCII = ' "${OUT13}/task13_result.txt" > "${OUT13}/task13_decrypt_check.txt"

grep '^M ASCII = ' "${OUT14}/task14_result.txt" > "${OUT14}/task14_plaintext_ascii.txt"
grep '^M hex = ' "${OUT14}/task14_result.txt" > "${OUT14}/task14_plaintext_hex.txt"

grep '^S1 hex = ' "${OUT15}/task15_result.txt" > "${OUT15}/task15_signature_original.txt"
grep '^S2 hex = ' "${OUT15}/task15_result.txt" > "${OUT15}/task15_signature_modified.txt"
