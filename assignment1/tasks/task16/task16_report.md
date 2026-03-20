## Task 16 Report (Verifying a Message)

### 1) What Was Done
I implemented RSA signature verification using OpenSSL BIGNUM by checking whether `S^e mod n` equals the message integer for the provided message/signature pair, and repeated the check after corrupting the signature byte (`2F -> 3F`).

- Source code: [task16_verify_bn.c](./task16_verify_bn.c)
- Runner script: [task16_verify.sh](./task16_verify.sh)

### 2) Verification Result for the Given (M, S)
Evidence: [task16_result.txt](./output/task16_result.txt)

Result: **INVALID**.

Brief explanation: `S^e mod n` recovered `4C61756E63682061206D697373696C652E`, while the provided message `M = "Launch a missle."` is `4C61756E63682061206D6973736C652E`; these are different, so the signature does not match the provided message.

### 3) After Corrupting the Last Byte (2F -> 3F)
Evidence: [task16_result.txt](./output/task16_result.txt), [task16_verification_summary.txt](./output/task16_verification_summary.txt)

Result: **INVALID** as expected.

Brief explanation: changing one byte in the RSA signature produces a completely different `S'^e mod n` value, so verification fails.

### 4) Tools and Methods Used
- C + OpenSSL BIGNUM (`BN_mod_exp`, `BN_cmp`)
- Deterministic verification script with saved text evidence
