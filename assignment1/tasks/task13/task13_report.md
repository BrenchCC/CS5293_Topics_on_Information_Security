## Task 13 Report (Encrypting a Message)

### 1) What Was Done
Using the provided RSA public key `(e, n)`, I encrypted `M = "A top secret!"` by converting ASCII -> hex -> BIGNUM and computing `C = M^e mod n`.
The implementation is reused from [task12_15_rsa_bn.c](../task12/task12_15_rsa_bn.c), and this task is reproduced via [task13_encrypt.sh](./task13_encrypt.sh).


### 2) Message Encoding and Ciphertext
Evidence: [task13_result.txt](./output/task13_result.txt)

- Message hex used: `4120746f702073656372657421`
- Ciphertext hex:
  `6FB078DA550B2650832661E14F4F8D2CFAEF475A0DF3A75CACDC5DE5CFC5FADC`

Extracted artifacts:
- [task13_message_hex.txt](./output/task13_message_hex.txt)
- [task13_ciphertext_hex.txt](./output/task13_ciphertext_hex.txt)

### 3) Encryption/Decryption Consistency
I verified consistency using the provided private key `d` by decrypting the computed ciphertext and obtaining the original plaintext.

Evidence: [task13_decrypt_check.txt](./output/task13_decrypt_check.txt)

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mod_exp`)
- ASCII/hex conversion in C
