## Task 12 Report (Deriving the Private Key)

### 1) What Was Done
I implemented RSA big-number computations using OpenSSL BIGNUM APIs and computed `n`, `phi(n)`, and the private key `d` for the provided `(p, q, e)`.

- Source code: [task12_15_rsa_bn.c](./task12_15_rsa_bn.c)
- Automation script: [task12_15_rsa.sh](./task12_15_rsa.sh)


### 2) Computed Results
Main evidence: [task12_result.txt](./output/task12_result.txt)

Computed values:
- `phi(n) = E103ABD94892E3E74AFD724BF28E78348D52298BD687C44DEB3A81065A7981A4`
- `d = 3587A24598E5F2A21DB007D89D18CC50ABA5075BA19A33890FE7C28A9B496AEB`

Extracted files:
- [task12_phi.txt](./output/task12_phi.txt)
- [task12_private_key.txt](./output/task12_private_key.txt)

### 3) Correctness Check
I verified the modular inverse condition:
- `(e * d) mod phi(n) = 01`
- Evidence: [task12_check.txt](./output/task12_check.txt)

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mul`, `BN_sub`, `BN_mod_inverse`, `BN_mod_mul`)
- Build: `gcc` with OpenSSL linkage
