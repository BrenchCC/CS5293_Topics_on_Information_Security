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

## Task 03 Report (Encryption Mode: ECB vs. CBC)

### 1) What Was Done
I encrypted BMP images with AES-128 in two modes: `-aes-128-ecb` and `-aes-128-cbc`.
The automation script is [task03_ecb_cbc_bmp.sh](./tasks/task03/task03_ecb_cbc_bmp.sh), and this task follows [AGENTS.md](../AGENTS.md).

The script processes:
- The provided image [pic_original.bmp](./assignment1-supplymentary/pic_original.bmp)
- A personal image generated from the provided image by resizing + rotating ([own_picture.bmp](./tasks/task03/output/own_picture.bmp))

### 2) Screenshot Evidence (Provided Picture)
Original and encrypted views (after keeping BMP header viewable):
- Original: [provided_original.png](./tasks/task03/screenshots/provided_original.png)
- ECB encrypted: [provided_ecb.png](./tasks/task03/screenshots/provided_ecb.png)
- CBC encrypted: [provided_cbc.png](./tasks/task03/screenshots/provided_cbc.png)

### 3) Screenshot Evidence (Own Picture)
Original and encrypted views:
- Original: [own_original.png](./tasks/task03/screenshots/own_original.png)
- ECB encrypted: [own_ecb.png](./tasks/task03/screenshots/own_ecb.png)
- CBC encrypted: [own_cbc.png](./tasks/task03/screenshots/own_cbc.png)

### 4) Can Useful Information Be Derived from the Encrypted Image?
Yes, from ECB-encrypted images, visible structural patterns and approximate object/layout boundaries can still be inferred. In contrast, CBC-encrypted images appear much more random, and useful visual information about the original content is largely hidden.

### 5) Brief Observations
ECB encrypts identical plaintext blocks into identical ciphertext blocks, so repeated visual patterns remain visible in the encrypted image. CBC introduces chaining with an IV, which breaks these repeating visual patterns and produces a more noise-like output.

### 6) Tools and Methods Used
- OpenSSL `enc` with `-aes-128-ecb` and `-aes-128-cbc`
- `dd` and `cat` to keep BMP header and rebuild encrypted BMP files
- `sips` to export PNG screenshot evidence files
- Size summary artifact: [task03_summary.txt](./tasks/task03/output/task03_summary.txt)

## Task 04 Report (Padding)

### 1) What Was Done
I conducted padding experiments for AES-128 in ECB/CBC/CFB/OFB modes and then inspected PKCS padding behavior using 5-byte, 10-byte, and 16-byte plaintext files.
The automation script is [task04_padding.sh](./tasks/task04/task04_padding.sh), and this task follows [AGENTS.md](../AGENTS.md).

### 2) ECB/CBC/CFB/OFB: Which Modes Use Padding?
Using a 21-byte plaintext, I compared ciphertext sizes across modes.
Evidence: [mode_padding_sizes.txt](./tasks/task04/output/mode_padding_sizes.txt)

Observed results:
- ECB: 32 bytes
- CBC: 32 bytes
- CFB: 21 bytes
- OFB: 21 bytes

Conclusion:
- ECB and CBC use block padding (PKCS#7 by default in OpenSSL `enc`).
- CFB and OFB do not require padding because they operate like stream modes and can process partial blocks directly.

### 3) 5/10/16-Byte CBC Files: Encrypted Sizes and Padding Bytes
Files created and encrypted with AES-128-CBC:
- Inputs: [f5.txt](./tasks/task04/output/f5.txt), [f10.txt](./tasks/task04/output/f10.txt), [f16.txt](./tasks/task04/output/f16.txt)
- Ciphertexts: [f5.cbc.enc](./tasks/task04/output/f5.cbc.enc), [f10.cbc.enc](./tasks/task04/output/f10.cbc.enc), [f16.cbc.enc](./tasks/task04/output/f16.cbc.enc)

Encrypted sizes evidence: [cbc_file_sizes.txt](./tasks/task04/output/cbc_file_sizes.txt)
- `f5.cbc.enc`: 16 bytes
- `f10.cbc.enc`: 16 bytes
- `f16.cbc.enc`: 32 bytes

Padding-byte evidence (using `-nopad` decryption + hex view):
- Evidence file: [padding_last_block_hex.txt](./tasks/task04/output/padding_last_block_hex.txt)
- `f5` last block: `31323334350b0b0b0b0b0b0b0b0b0b0b` (11 bytes of `0x0b`)
- `f10` last block: `31323334353637383930060606060606` (6 bytes of `0x06`)
- `f16` last block: `10101010101010101010101010101010` (full extra block of `0x10`)

### 4) Brief Summary of PKCS#5/PKCS#7 Pattern
The padding value equals the number of padding bytes added. When plaintext length is already one full block (16 bytes for AES), a full block of padding is appended (16 bytes of `0x10`).

### 5) Tools and Methods Used
- OpenSSL `enc` with AES-128 ECB/CBC/CFB/OFB
- OpenSSL `-nopad` during decryption for raw padded plaintext inspection
- `xxd` and `wc` for hex/size evidence

## Task 05 Report (Error Propagation: Corrupted Ciphertext)

### 1) What Was Done
I created a plaintext file longer than 1000 bytes, encrypted it with AES-128 in ECB/CBC/CFB/OFB, flipped one bit in ciphertext byte #55, and decrypted with the correct key/IV.
The automation script is [task05_error_propagation.sh](./tasks/task05/task05_error_propagation.sh), and this task follows [AGENTS.md](../AGENTS.md).

### 2) Prediction Before Running the Experiment
Prediction evidence: [prediction.txt](./tasks/task05/output/prediction.txt)

- ECB: one full plaintext block is corrupted.
- CBC: current block corrupted + one bit flip in next block.
- CFB (128-bit): one bit flip in current block + next block corruption.
- OFB: only the corresponding bit flips, no further propagation.

### 3) Experimental Evidence
Main summary: [corruption_summary.txt](./tasks/task05/output/corruption_summary.txt)

Observed:
- ECB: `different_bytes=16`, first diff at 49, last diff at 64.
- CBC: `different_bytes=17`, first diff at 49, last diff at 71.
- CFB: `different_bytes=17`, first diff at 55, last diff at 80.
- OFB: `different_bytes=1`, only at position 55.

Hex snippets around the affected region:
- [snippet_ecb.txt](./tasks/task05/output/snippet_ecb.txt)
- [snippet_cbc.txt](./tasks/task05/output/snippet_cbc.txt)
- [snippet_cfb.txt](./tasks/task05/output/snippet_cfb.txt)
- [snippet_ofb.txt](./tasks/task05/output/snippet_ofb.txt)

### 4) Comparison: Prediction vs. Observation
The results match the prediction pattern for all four modes. OFB showed strictly local bit-flip behavior, while CBC/CFB showed additional propagation due to block chaining/feedback dependencies, and ECB isolated corruption to one block.

### 5) Tools and Methods Used
- OpenSSL `enc` with AES-128 ECB/CBC/CFB/OFB
- One-bit ciphertext corruption via binary byte edit script
- `cmp -l` and `xxd` for location and byte-level evidence

## Task 06 Report (Initial Vector, IV)

### 1) What Was Done
I completed Task 6.1 (IV uniqueness), Task 6.2 (OFB known-plaintext recovery), and Task 6.3 (predictable-IV chosen-plaintext attack on CBC).
The automation script is [task06_iv_experiments.sh](./tasks/task06/task06_iv_experiments.sh), and this task follows [AGENTS.md](../AGENTS.md).

### 2) Task 6.1: IV Uniqueness Observation
Evidence: [task61_observation.txt](./tasks/task06/output/task61_observation.txt)

First-block ciphertexts for the same plaintext under AES-128-CBC:
- IV1 first run: `c40201ad66afcc48f86c14bbb9d9d4d8`
- IV2 run: `74112c76433b7e6847bb4d62f5071807`
- IV1 second run: `c40201ad66afcc48f86c14bbb9d9d4d8`

Observation: Reusing the same IV with the same key/plaintext gives the same first ciphertext block, while changing IV changes it. This is why IV uniqueness is required.

### 3) Task 6.2: Recovering P2 in OFB
Evidence: [task62_recovery.txt](./tasks/task06/output/task62_recovery.txt)

Recovered plaintext:
- `P2 = Order: Launch a missile!`

Method (brief): In OFB, ciphertext is plaintext XOR keystream. With reused IV, the same keystream is reused, so `P2 = C2 XOR C1 XOR P1`.

CFB answer: only the first plaintext block of `P2` can be directly revealed in this setting; later blocks depend on unknown `E_K(C2_{i-1})`.

### 4) Task 6.3: Predictable-IV Chosen-Plaintext Attack (CBC)
Evidence: [task63_attack_result.txt](./tasks/task06/output/task63_attack_result.txt)

Chosen plaintexts and oracle ciphertexts:
- Yes-test `P2` hex: `5965730d0d0d0d0d0d0d0d0d0d0d0d0c`
- Oracle `C2` (Yes-test): `bef65565572ccee2a9f9553154ed9498`
- Target `C1`: `bef65565572ccee2a9f9553154ed9498`

Since `C2 == C1` for the Yes-test, the hidden original message `P1` is inferred to be `Yes`.

### 5) Tools and Methods Used
- OpenSSL `enc` with AES-128-CBC/OFB
- XOR-based keystream recovery for OFB
- Chosen-plaintext construction for predictable-IV CBC attack

## Task 07 Report (Programming with Crypto Library)

### 1) What Was Done
I implemented a C brute-force program using OpenSSL EVP APIs to recover the AES-128-CBC key from the provided plaintext/ciphertext/IV pair, under the rule that the key is an English word padded with `#` to 16 bytes.
The source code is [task07_bruteforce.c](./tasks/task07/task07_bruteforce.c), and this task follows [AGENTS.md](../AGENTS.md).

### 2) Build and Run
Compile command (with crypto library):
- `gcc -Wall -Wextra -O2 -o task07_bruteforce task07_bruteforce.c $(pkg-config --cflags --libs openssl)`

Run command:
- `./task07_bruteforce`

Program output evidence: [task07_bruteforce_result.txt](./tasks/task07/output/task07_bruteforce_result.txt)

### 3) Recovered Key and Correctness Evidence
Recovered dictionary word key:
- `Syracuse`

Recovered 128-bit padded key:
- ASCII: `Syracuse########`
- Hex: `53797261637573652323232323232323`

Correctness evidence:
- Program decrypted the ciphertext to exactly `This is a top secret.`

### 4) Dictionary Source/Strategy
I used the provided word list [words.txt](./assignment1-supplymentary/words.txt). The strategy was exhaustive dictionary search: for each word shorter than 16 bytes, pad with `#` to 16 bytes, decrypt with AES-128-CBC, and compare against the known target plaintext.

### 5) Tools and Methods Used
- C + OpenSSL EVP (`EVP_DecryptInit_ex`, `EVP_DecryptUpdate`, `EVP_DecryptFinal_ex`)
- `gcc` with OpenSSL crypto linkage
- Dictionary-based brute-force key search
