#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${BASE_DIR}/output"
mkdir -p "${OUT_DIR}"

KEY_HEX="00112233445566778899aabbccddeeff"
IV1_HEX="0102030405060708090a0b0c0d0e0f10"
IV2_HEX="1112131415161718191a1b1c1d1e1f20"

# Task 6.1: IV uniqueness demonstration (CBC)
printf "Message for IV uniqueness demo." > "${OUT_DIR}/iv_plain.txt"
openssl enc -aes-128-cbc -e -nosalt -in "${OUT_DIR}/iv_plain.txt" -out "${OUT_DIR}/iv_case_a.bin" -K "${KEY_HEX}" -iv "${IV1_HEX}"
openssl enc -aes-128-cbc -e -nosalt -in "${OUT_DIR}/iv_plain.txt" -out "${OUT_DIR}/iv_case_b.bin" -K "${KEY_HEX}" -iv "${IV2_HEX}"
openssl enc -aes-128-cbc -e -nosalt -in "${OUT_DIR}/iv_plain.txt" -out "${OUT_DIR}/iv_case_c.bin" -K "${KEY_HEX}" -iv "${IV1_HEX}"

FIRST_A="$(xxd -p -l 16 "${OUT_DIR}/iv_case_a.bin")"
FIRST_B="$(xxd -p -l 16 "${OUT_DIR}/iv_case_b.bin")"
FIRST_C="$(xxd -p -l 16 "${OUT_DIR}/iv_case_c.bin")"

{
  echo "Task 6.1 first-block ciphertext snippets (CBC):"
  echo "IV1 first run : ${FIRST_A}"
  echo "IV2 run       : ${FIRST_B}"
  echo "IV1 second run: ${FIRST_C}"
  echo "IV1 first run == IV1 second run ? $( [[ "${FIRST_A}" == "${FIRST_C}" ]] && echo yes || echo no )"
  echo "IV1 first run == IV2 run ? $( [[ "${FIRST_A}" == "${FIRST_B}" ]] && echo yes || echo no )"
} > "${OUT_DIR}/task61_observation.txt"

# Task 6.2: OFB known-plaintext recovery
P1_ASCII='This is a known message!'
C1_HEX='a469b1c502c1cab966965e50425438e1bb1b5f9037a4c159'
C2_HEX='bf73bcd3509299d566c35b5d450337e1bb175f903fafc159'

P1_HEX="$(printf '%s' "${P1_ASCII}" | xxd -p -c 999)"
P2_HEX="$(perl -e '
  use strict;
  use warnings;
  my ($p1_hex, $c1_hex, $c2_hex) = @ARGV;
  my $p1 = pack("H*", $p1_hex);
  my $c1 = pack("H*", $c1_hex);
  my $c2 = pack("H*", $c2_hex);
  my $len = length($p1);
  my $out = "";
  for (my $i = 0; $i < $len; $i++) {
    $out .= chr(ord(substr($p1,$i,1)) ^ ord(substr($c1,$i,1)) ^ ord(substr($c2,$i,1)));
  }
  print unpack("H*", $out);
' "${P1_HEX}" "${C1_HEX}" "${C2_HEX}")"

P2_ASCII="$(printf '%s' "${P2_HEX}" | xxd -r -p)"

{
  echo "Task 6.2 OFB recovery"
  echo "Given P1: ${P1_ASCII}"
  echo "Recovered P2 hex  : ${P2_HEX}"
  echo "Recovered P2 text : ${P2_ASCII}"
  echo "CFB answer: with IV reuse, only the first plaintext block of P2 can be directly revealed from known P1/C1/C2 context; later blocks depend on unknown E_K(C2_{i-1})."
} > "${OUT_DIR}/task62_recovery.txt"

# Task 6.3: predictable-IV chosen-plaintext attack against CBC
# Known values from assignment
C1_TARGET_HEX='bef65565572ccee2a9f9553154ed9498'
IV_USED_P1_HEX='31323334353637383930313233343536'   # "1234567890123456"
IV_NEXT_HEX='31323334353637383930313233343537'      # "1234567890123457"

# Candidate padded blocks for P1
YES_PAD_HEX='5965730d0d0d0d0d0d0d0d0d0d0d0d0d'
NO_PAD_HEX='4e6f0e0e0e0e0e0e0e0e0e0e0e0e0e0e'

# Build chosen plaintext block: P2 = candidate XOR IV_used_on_P1 XOR IV_next
build_p2_hex() {
  local cand_hex="$1"
  perl -e '
    use strict;
    use warnings;
    my ($cand_hex, $iv1_hex, $iv2_hex) = @ARGV;
    my $cand = pack("H*", $cand_hex);
    my $iv1 = pack("H*", $iv1_hex);
    my $iv2 = pack("H*", $iv2_hex);
    my $out = "";
    for (my $i = 0; $i < length($cand); $i++) {
      $out .= chr(ord(substr($cand,$i,1)) ^ ord(substr($iv1,$i,1)) ^ ord(substr($iv2,$i,1)));
    }
    print unpack("H*", $out);
  ' "$cand_hex" "$IV_USED_P1_HEX" "$IV_NEXT_HEX"
}

P2_YES_HEX="$(build_p2_hex "${YES_PAD_HEX}")"
P2_NO_HEX="$(build_p2_hex "${NO_PAD_HEX}")"

printf '%s' "${P2_YES_HEX}" | xxd -r -p > "${OUT_DIR}/task63_p2_yes.bin"
printf '%s' "${P2_NO_HEX}" | xxd -r -p > "${OUT_DIR}/task63_p2_no.bin"

# Simulate Bob oracle encryption under next IV and secret key (known here only for lab execution)
openssl enc -aes-128-cbc -e -nosalt -nopad -in "${OUT_DIR}/task63_p2_yes.bin" -out "${OUT_DIR}/task63_c2_yes.bin" -K "${KEY_HEX}" -iv "${IV_NEXT_HEX}"
openssl enc -aes-128-cbc -e -nosalt -nopad -in "${OUT_DIR}/task63_p2_no.bin" -out "${OUT_DIR}/task63_c2_no.bin" -K "${KEY_HEX}" -iv "${IV_NEXT_HEX}"

C2_YES_HEX="$(xxd -p -c 999 "${OUT_DIR}/task63_c2_yes.bin")"
C2_NO_HEX="$(xxd -p -c 999 "${OUT_DIR}/task63_c2_no.bin")"

RESULT="unknown"
if [[ "${C2_YES_HEX}" == "${C1_TARGET_HEX}" ]]; then
  RESULT="P1 is Yes"
elif [[ "${C2_NO_HEX}" == "${C1_TARGET_HEX}" ]]; then
  RESULT="P1 is No"
fi

{
  echo "Task 6.3 predictable-IV chosen-plaintext attack"
  echo "Target C1               : ${C1_TARGET_HEX}"
  echo "Chosen P2 (Yes-test) hex: ${P2_YES_HEX}"
  echo "Oracle C2 for Yes-test  : ${C2_YES_HEX}"
  echo "Chosen P2 (No-test) hex : ${P2_NO_HEX}"
  echo "Oracle C2 for No-test   : ${C2_NO_HEX}"
  echo "Inference               : ${RESULT}"
} > "${OUT_DIR}/task63_attack_result.txt"
