## Task 15 Report (Signing a Message)

### 1) What Was Done
Using the same RSA private key from Task 13/14, I signed two messages directly (without hashing) via `S = M^d mod n`:
- Original: `I owe you $2000.`
- Modified: `I owe you $3000.`

The implementation is reused from [task12_15_rsa_bn.c](../task12/task12_15_rsa_bn.c), and this task is reproduced via [task15_sign.sh](./task15_sign.sh).


### 2) Signatures (Hex)
Evidence: [task15_result.txt](./output/task15_result.txt)

- Signature for original message:
  `55A4E7F17F04CCFE2766E1EB32ADDBA890BBE92A6FBE2D785ED6E73CCB35E4CB`
- Signature for modified message:
  `BCC20FB7568E5D48E434C387C06A6025E90D29D848AF9C3EBAC0135D99305822`

Extracted artifacts:
- [task15_signature_original.txt](./output/task15_signature_original.txt)
- [task15_signature_modified.txt](./output/task15_signature_modified.txt)

### 3) Observation
A very small plaintext change (`$2000` -> `$3000`) produced a completely different RSA signature value, showing strong sensitivity of the RSA modular-exponentiation output to message content.

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mod_exp`)
- ASCII/hex conversion in C
