## Task 14 Report (Decrypting a Message)

### 1) What Was Done
Using the same RSA key pair from Task 13, I decrypted the provided ciphertext with `M = C^d mod n`, then converted the hex/plain bytes into an ASCII string.
The implementation is reused from [task12_15_rsa_bn.c](../task12/task12_15_rsa_bn.c), and this task is reproduced via [task14_decrypt.sh](./task14_decrypt.sh).


### 2) Decryption Result
Evidence: [task14_result.txt](./output/task14_result.txt)

- Decrypted hex: `50617373776F72642069732064656573`
- Decrypted ASCII: `Password is dees`

Extracted artifacts:
- [task14_plaintext_hex.txt](./output/task14_plaintext_hex.txt)
- [task14_plaintext_ascii.txt](./output/task14_plaintext_ascii.txt)

### 3) Brief Method Summary
I represented all RSA values as BIGNUMs and applied modular exponentiation for decryption, then rendered the resulting bytes as ASCII characters.

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mod_exp`)
- Hex/ASCII conversion in C
