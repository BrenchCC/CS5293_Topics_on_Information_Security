## Task 02 Report (OpenSSL enc with Multiple Ciphers)

### 1) What Was Done
I tested OpenSSL encryption/decryption with three cipher options: `-aes-128-cbc`, `-aes-128-cfb`, and `-aes-128-ofb`.
The full procedure is automated in [task02_openssl_enc_test.sh](./task02_openssl_enc_test.sh), using the input file [words.txt](../../assignment1-supplymentary/words.txt).
This task follows the project instruction file [AGENTS.md](../../../AGENTS.md).

### 2) Key Evidence and Results
For each cipher, I encrypted and then decrypted the same plaintext, and verified correctness by both checksum matching and `diff`.

- Cipher list artifact: [cipher_list.txt](./output/cipher_list.txt)
- SHA-256 verification log: [verification_sha256.txt](./output/verification_sha256.txt)
- Diff verification log: [verification_diff.txt](./output/verification_diff.txt)
- Ciphertext hash comparison: [ciphertext_sha256.txt](./output/ciphertext_sha256.txt)
- Screenshot evidence: [task02_verification_snapshot.txt.png](./output/task02_verification_snapshot.txt.png)

All three ciphers produced correct decryption results:
- `sha256(original) == sha256(decrypted)` for each cipher.
- `diff` returned identical content for each cipher.

Encrypted outputs are stored as:
- [words_aes-128-cbc.enc](./output/words_aes-128-cbc.enc)
- [words_aes-128-cfb.enc](./output/words_aes-128-cfb.enc)
- [words_aes-128-ofb.enc](./output/words_aes-128-ofb.enc)

### 3) Brief Observations
The three modes generate different ciphertext bytes for the same plaintext/key/IV, which confirms that mode selection materially changes encryption behavior. Also, CBC output is larger here because it uses padding, while CFB/OFB keep ciphertext length equal to plaintext length.

### 4) Tools and Methods Used
- OpenSSL `enc` command with `-e`, `-d`, `-in`, `-out`, `-K`, and `-iv`
- `sha256sum` for integrity comparison
- `diff` for exact plaintext equality check
