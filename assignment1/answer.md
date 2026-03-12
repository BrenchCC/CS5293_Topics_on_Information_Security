# Assignment 1 Report

## Task 01 Report (Monoalphabetic Substitution Cipher)

### 1) Recovered Substitution Mapping (Ciphertext -> Plaintext)

All 26 letters were recovered; no unknown mappings remain.

| Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| a | c | b | f | c | m | d | y | e | p | f | v | g | b |
| h | r | i | l | j | q | k | x | l | w | m | i | n | e |
| o | j | p | d | q | s | r | g | s | k | t | h | u | n |
| v | a | w | z | x | o | y | t | z | u |  |  |  |  |

### 2) A Short Excerpt of the Recovered Plaintext

See [plaintext_excerpt.txt](./tasks/task01/output/plaintext_excerpt.txt):

> the oscars turn on sunday which seems about right after this long strange awards trip the bagger feels like a nonagenarian too
>
> the awards race was bookended by the demise of harvey weinstein at its outset and the apparent implosion of

### 3) Frequency-Analysis Evidence

Key evidence:
- High-frequency trigram `ytn` -> `the` (see [trigram_top.txt](./tasks/task01/output/trigram_top.txt)).
- Frequent short word `vup` -> `and`.
- Word pattern `xqavhq` -> `oscars`, confirming `x -> o, q -> s, a -> c, v -> a, h -> r`.
- Proper noun pattern `lnmuqynmu` -> `weinstein`, validating several mappings together.
- N-gram frequencies become consistent with English after substitution (see [unigram_top.txt](./tasks/task01/output/unigram_top.txt), [bigram_top.txt](./tasks/task01/output/bigram_top.txt), and [trigram_top.txt](./tasks/task01/output/trigram_top.txt)).

### 4) Tools and Methods Used
- Bash script: [task01_decrypt.sh](./tasks/task01/task01_decrypt.sh)
- Outputs: [plaintext.txt](./tasks/task01/output/plaintext.txt) and [mapping_cipher_to_plain.txt](./tasks/task01/output/mapping_cipher_to_plain.txt)
- Command-line tools: `tr`, `awk`, `sort`, `uniq`, `head`
- Project instructions: [AGENTS.md](../AGENTS.md)

## Task 02 Report (OpenSSL enc with Multiple Ciphers)

### 1) What Was Done
I tested OpenSSL encryption/decryption with three cipher options: `-aes-128-cbc`, `-aes-128-cfb`, and `-aes-128-ofb`.
The full procedure is automated in [task02_openssl_enc_test.sh](./tasks/task02/task02_openssl_enc_test.sh), using the input file [words.txt](./assignment1-supplymentary/words.txt).
This task follows the project instruction file [AGENTS.md](../AGENTS.md).

### 2) Key Evidence and Results
For each cipher, I encrypted and then decrypted the same plaintext, and verified correctness by both checksum matching and `diff`.

- Cipher list artifact: [cipher_list.txt](./tasks/task02/output/cipher_list.txt)
- SHA-256 verification log: [verification_sha256.txt](./tasks/task02/output/verification_sha256.txt)
- Diff verification log: [verification_diff.txt](./tasks/task02/output/verification_diff.txt)
- Ciphertext hash comparison: [ciphertext_sha256.txt](./tasks/task02/output/ciphertext_sha256.txt)
- Screenshot evidence: [task02_verification_snapshot.txt.png](./tasks/task02/output/task02_verification_snapshot.txt.png)

All three ciphers produced correct decryption results:
- `sha256(original) == sha256(decrypted)` for each cipher.
- `diff` returned identical content for each cipher.

Encrypted outputs are stored as:
- [words_aes-128-cbc.enc](./tasks/task02/output/words_aes-128-cbc.enc)
- [words_aes-128-cfb.enc](./tasks/task02/output/words_aes-128-cfb.enc)
- [words_aes-128-ofb.enc](./tasks/task02/output/words_aes-128-ofb.enc)

### 3) Brief Observations
The three modes generate different ciphertext bytes for the same plaintext/key/IV, which confirms that mode selection materially changes encryption behavior. Also, CBC output is larger here because it uses padding, while CFB/OFB keep ciphertext length equal to plaintext length.

### 4) Tools and Methods Used
- OpenSSL `enc` command with `-e`, `-d`, `-in`, `-out`, `-K`, and `-iv`
- `sha256sum` for integrity comparison
- `diff` for exact plaintext equality check
