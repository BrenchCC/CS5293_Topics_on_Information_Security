## Task 17 Report (Manually Verifying an X.509 Certificate)

### 1) What Was Done
I manually verified the server certificate for `www.chase.com` by extracting the issuer public key `(e, n)`, extracting the server-certificate signature, extracting the TBSCertificate body, hashing it with SHA-256, and verifying the RSA PKCS#1 v1.5 signature using my own C program.

- Runner script: [task17_manual_verify.sh](./task17_manual_verify.sh)
- Verification program: [task17_verify_cert_bn.c](./task17_verify_cert_bn.c)

### 2) Website and Certificate Chain Files
Website used: **www.chase.com**.

Certificate files created:
- Leaf certificate: [c0.pem](./output/c0.pem)
- Issuer certificate: [c1.pem](./output/c1.pem)
- Additional chain certificate: [c2.pem](./output/c2.pem)

Raw chain capture: [task17_s_client_raw.txt](./output/task17_s_client_raw.txt)

### 3) Extracted Data and Hash
Main evidence: [task17_result.txt](./output/task17_result.txt)

Additional extracted artifacts:
- Issuer modulus `n`: [issuer_n_hex.txt](./output/issuer_n_hex.txt)
- Issuer exponent `e`: [issuer_e_hex.txt](./output/issuer_e_hex.txt)
- Certificate signature hex: [signature_hex.txt](./output/signature_hex.txt)
- Certificate body hash: [c0_body_sha256.txt](./output/c0_body_sha256.txt)

### 4) Program Verification Evidence
My program output is stored in [task17_verify_result.txt](./output/task17_verify_result.txt).

Result: **VALID**.

### 5) Tools and Methods Used
- `openssl s_client`, `openssl x509`, `openssl asn1parse`, `sha256sum`
- C + OpenSSL (`BN_mod_exp`, `SHA256`) with PKCS#1 v1.5 DigestInfo validation for SHA-256
