#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"
SRC="${SCRIPT_DIR}/task17_verify_cert_bn.c"
BIN="${OUT_DIR}/task17_verify_cert_bn"

mkdir -p "${OUT_DIR}"

RAW="${OUT_DIR}/task17_s_client_raw.txt"
if [ ! -s "${RAW}" ]; then
    openssl s_client -connect www.chase.com:443 -servername www.chase.com -showcerts </dev/null > "${RAW}" 2>&1
fi

awk 'BEGIN{n=0;inside=0} /-----BEGIN CERTIFICATE-----/{inside=1;n++;out=sprintf("%s/c%d.pem", d, n-1)} inside{print > out} /-----END CERTIFICATE-----/{inside=0}' d="${OUT_DIR}" "${RAW}"

openssl x509 -in "${OUT_DIR}/c0.pem" -noout -subject -issuer > "${OUT_DIR}/task17_subject_issuer.txt"
openssl x509 -in "${OUT_DIR}/c1.pem" -noout -modulus | sed 's/^Modulus=//' | tr '[:lower:]' '[:upper:]' > "${OUT_DIR}/issuer_n_hex.txt"

openssl x509 -in "${OUT_DIR}/c1.pem" -text -noout > "${OUT_DIR}/c1_text.txt"
EXP_HEX=$(grep -m1 'Exponent:' "${OUT_DIR}/c1_text.txt" | sed -E 's/.*\((0x[0-9a-fA-F]+)\).*/\1/' | sed 's/^0x//' | tr '[:lower:]' '[:upper:]')
if [ $(( ${#EXP_HEX} % 2 )) -eq 1 ]; then
    EXP_HEX="0${EXP_HEX}"
fi
printf '%s\n' "${EXP_HEX}" > "${OUT_DIR}/issuer_e_hex.txt"

openssl asn1parse -i -in "${OUT_DIR}/c0.pem" > "${OUT_DIR}/c0_asn1.txt"
openssl asn1parse -i -in "${OUT_DIR}/c0.pem" -strparse 4 -out "${OUT_DIR}/c0_body.bin" -noout
sha256sum "${OUT_DIR}/c0_body.bin" > "${OUT_DIR}/c0_body_sha256.txt"

openssl x509 -in "${OUT_DIR}/c0.pem" -outform DER -out "${OUT_DIR}/c0.der"
SIG_OFFSET=$(openssl asn1parse -inform DER -in "${OUT_DIR}/c0.der" -i | awk '/prim:[[:space:]]+BIT STRING/{line=$0} END{sub(/^[[:space:]]*/, "", line); split(line, a, ":"); print a[1]}')
openssl asn1parse -inform DER -in "${OUT_DIR}/c0.der" -strparse "${SIG_OFFSET}" -out "${OUT_DIR}/signature_with_unused.bin" -noout

# OpenSSL -strparse on a BIT STRING offset returns raw signature bytes directly.
cp "${OUT_DIR}/signature_with_unused.bin" "${OUT_DIR}/signature.bin"
xxd -p -c 100000 "${OUT_DIR}/signature.bin" | tr -d '\n' | tr '[:lower:]' '[:upper:]' > "${OUT_DIR}/signature_hex.txt"
printf '\n' >> "${OUT_DIR}/signature_hex.txt"

gcc -Wall -Wextra -O2 -o "${BIN}" "${SRC}" $(pkg-config --cflags --libs openssl)
"${BIN}" "${OUT_DIR}/issuer_n_hex.txt" "${OUT_DIR}/issuer_e_hex.txt" "${OUT_DIR}/signature_hex.txt" "${OUT_DIR}/c0_body.bin" > "${OUT_DIR}/task17_verify_result.txt"

{
    echo "Website: www.chase.com"
    echo "Certificate files: c0.pem (leaf), c1.pem (issuer), c2.pem (root/intermediate)"
    echo
    echo "Issuer modulus (n) head:"
    head -c 64 "${OUT_DIR}/issuer_n_hex.txt"; echo "..."
    echo "Issuer exponent (e):"
    cat "${OUT_DIR}/issuer_e_hex.txt"
    echo
    echo "Signature hex head:"
    head -c 64 "${OUT_DIR}/signature_hex.txt"; echo "..."
    echo
    echo "SHA256(c0_body.bin):"
    cat "${OUT_DIR}/c0_body_sha256.txt"
    echo
    echo "Program verification output:"
    cat "${OUT_DIR}/task17_verify_result.txt"
} > "${OUT_DIR}/task17_result.txt"

cat "${OUT_DIR}/task17_result.txt"
