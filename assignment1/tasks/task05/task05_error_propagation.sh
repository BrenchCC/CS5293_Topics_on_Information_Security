#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${BASE_DIR}/output"
KEY_HEX="00112233445566778899aabbccddeeff"
IV_HEX="0102030405060708090a0b0c0d0e0f10"

mkdir -p "${OUT_DIR}"

awk 'BEGIN{for(i=0;i<300;i++)printf("LINE%04d-ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\\n", i)}' > "${OUT_DIR}/plain_1000plus.txt"

cat > "${OUT_DIR}/prediction.txt" <<'PRED'
Prediction before running the experiment (1-bit error at ciphertext byte #55):
- ECB: one full plaintext block (block containing byte #55) becomes garbled; others unaffected.
- CBC: current block becomes garbled, and the same bit position flips in the next block; others unaffected.
- CFB (128-bit segment): same bit flips in current block, next block becomes garbled, then recovery.
- OFB: only the corresponding plaintext bit flips; no propagation beyond that bit.
PRED

flip_byte_55_bit0() {
  local in_file="$1"
  local out_file="$2"
  perl -e '
    use strict;
    use warnings;
    local $/;
    my ($in, $out) = @ARGV;
    open my $fh_in, "<:raw", $in or die $!;
    my $data = <$fh_in>;
    close $fh_in;
    my $idx = 54; # 55th byte (1-based)
    substr($data, $idx, 1) = substr($data, $idx, 1) ^ "\x01";
    open my $fh_out, ">:raw", $out or die $!;
    print {$fh_out} $data;
    close $fh_out;
  ' "$in_file" "$out_file"
}

for mode in ecb cbc cfb ofb; do
  c_file="${OUT_DIR}/cipher_${mode}.bin"
  c_corrupt_file="${OUT_DIR}/cipher_${mode}_corrupt.bin"
  d_corrupt_file="${OUT_DIR}/decrypted_${mode}_corrupt.txt"

  if [[ "${mode}" == "ecb" ]]; then
    openssl enc -aes-128-ecb -e -nosalt -in "${OUT_DIR}/plain_1000plus.txt" -out "${c_file}" -K "${KEY_HEX}"
    flip_byte_55_bit0 "${c_file}" "${c_corrupt_file}"
    openssl enc -aes-128-ecb -d -nosalt -in "${c_corrupt_file}" -out "${d_corrupt_file}" -K "${KEY_HEX}"
  else
    openssl enc -aes-128-${mode} -e -nosalt -in "${OUT_DIR}/plain_1000plus.txt" -out "${c_file}" -K "${KEY_HEX}" -iv "${IV_HEX}"
    flip_byte_55_bit0 "${c_file}" "${c_corrupt_file}"
    openssl enc -aes-128-${mode} -d -nosalt -in "${c_corrupt_file}" -out "${d_corrupt_file}" -K "${KEY_HEX}" -iv "${IV_HEX}"
  fi

  cmp -l "${OUT_DIR}/plain_1000plus.txt" "${d_corrupt_file}" > "${OUT_DIR}/cmp_${mode}.txt" || true

  {
    echo "=== ${mode} ==="
    if [[ -s "${OUT_DIR}/cmp_${mode}.txt" ]]; then
      awk 'NR==1{first=$1} {last=$1;count++} END{printf("different_bytes=%d first_diff_pos=%d last_diff_pos=%d\n", count, first, last)}' "${OUT_DIR}/cmp_${mode}.txt"
      echo "first_20_cmp_lines:"
      sed -n '1,20p' "${OUT_DIR}/cmp_${mode}.txt"
    else
      echo "different_bytes=0"
    fi
    echo
  } >> "${OUT_DIR}/corruption_summary.txt"

done

# Hex snippets around the affected region for visual evidence.
for mode in ecb cbc cfb ofb; do
  {
    echo "=== ${mode} plain snippet (offset 32, len 96) ==="
    xxd -g 1 -s 32 -l 96 "${OUT_DIR}/plain_1000plus.txt"
    echo "=== ${mode} decrypted_corrupt snippet (offset 32, len 96) ==="
    xxd -g 1 -s 32 -l 96 "${OUT_DIR}/decrypted_${mode}_corrupt.txt"
    echo
  } > "${OUT_DIR}/snippet_${mode}.txt"
done
