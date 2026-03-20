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

## Task 02 Report (OpenSSL enc with Multiple Ciphers)

### 1) What Was Done
I tested OpenSSL encryption/decryption with three cipher options: `-aes-128-cbc`, `-aes-128-cfb`, and `-aes-128-ofb`.
The full procedure is automated in [task02_openssl_enc_test.sh](./tasks/task02/task02_openssl_enc_test.sh), using the input file [words.txt](./assignment1-supplymentary/words.txt).

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

### 2) Prediction Before Running the Experiment
Prediction evidence: [prediction.txt](./tasks/task05/output/prediction.txt)

- ECB: one full plaintext block is corrupted.
- CBC: current block corrupted + one bit flip in next block.
- CFB (128-bit): one bit flip in current block + next block corruption.
- OFB: only the corresponding bit flips, no further propagation.

### 3) Experimental Evidence
Main summary: [corruption_summary.txt](./tasks/task05/output/corruption_summary.txt)
Screenshot-style snapshot: [task05_evidence_snapshot.txt.png](./tasks/task05/output/task05_evidence_snapshot.txt.png)

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

## Task 08 Report (Generating Two Different Files with the Same MD5 Hash)

### 1) What Was Done
I used `md5collgen` with two prefixes:
- A non-64-byte prefix: [prefix_non64.txt](./tasks/task08/output/prefix_non64.txt)
- An exactly 64-byte prefix: [prefix_64.txt](./tasks/task08/output/prefix_64.txt)


### 2) Evidence: Different Files, Same MD5
Evidence file: [task08_diff_md5.txt](./tasks/task08/output/task08_diff_md5.txt)

Results:
- `out1_non64.bin` and `out2_non64.bin` are different (`diff` reports binary difference), but both have MD5 `88085b538d8d9e243c91fd76fcca47ff`.
- `out1_64.bin` and `out2_64.bin` are different, but both have MD5 `7cc4cac2bcc2d538e6b7fa0b20858d78`.

Size summary: [task08_sizes.txt](./tasks/task08/output/task08_sizes.txt)

### 3) Answers to Question 1–3
Question 1 (prefix length not multiple of 64):
- Collision generation still succeeds. With a 27-byte prefix, both output files are different but share the same MD5.

Question 2 (prefix length exactly 64 bytes):
- Collision generation also succeeds. With a 64-byte prefix, outputs are different but share the same MD5.

Question 3 (are the 128 bytes completely different?):
- No. In this run, only a small subset of bytes differ in the 128-byte collision blocks.
- Exact differing positions are listed in [collision_block_diff_positions.txt](./tasks/task08/output/collision_block_diff_positions.txt).
- Hex evidence is in [block1_64.hex](./tasks/task08/output/block1_64.hex) and [block2_64.hex](./tasks/task08/output/block2_64.hex).

### 4) Tools and Methods Used
- Collision generator: `md5collgen`
- Validation tools: `diff`, `md5sum`, `cmp`, `dd`, `xxd`

## Task 09 Report (Understanding MD5’s Property)

### 1) Experiment Design
I selected the colliding pair from Task 08 as:
- `M = out1_64.bin`
- `N = out2_64.bin`

Then I created a common suffix file `T` and appended it to both files:
- `M || T`
- `N || T`

Automation script: [task09_md5_property.sh](./tasks/task09/task09_md5_property.sh)


### 2) Command Evidence
Main evidence file: [task09_md5_property.txt](./tasks/task09/output/task09_md5_property.txt)

Observed results:
- `MD5(M) = MD5(N) = 7cc4cac2bcc2d538e6b7fa0b20858d78`
- `MD5(M || T) = MD5(N || T) = 2fc5662f9d149f666a8566446f847f37`

Supplementary files:
- Suffix file: [suffix_T.bin](./tasks/task09/output/suffix_T.bin)
- Generated files: [M_plus_T.bin](./tasks/task09/output/M_plus_T.bin), [N_plus_T.bin](./tasks/task09/output/N_plus_T.bin)
- Size summary: [task09_sizes.txt](./tasks/task09/output/task09_sizes.txt)

### 3) Brief Explanation
MD5 is iterative over 64-byte blocks. If two inputs reach the same intermediate hash state at the end (`MD5(M) = MD5(N)`), appending the same suffix `T` feeds identical later blocks into identical internal states, so the final hashes remain equal.

### 4) Tools and Methods Used
- File concatenation: `cat`
- Hash verification: `md5sum`

## Task 10 Report (Generating Two Executable Files with the Same MD5 Hash)

### 1) What Was Done
I created a C program with a 200-byte global array `xyz` initialized to `0x41`, compiled it, located the array in the executable, split the binary into `prefix / 128-byte region / suffix`, generated a collision on the prefix, and rebuilt two executables.

Files:
- Source code: [task10_collision_exec.c](./tasks/task10/task10_collision_exec.c)
- Automation script: [task10_collision_exec.sh](./tasks/task10/task10_collision_exec.sh)


### 2) How the Executable Was Located and Split
Offset evidence: [task10_offsets.txt](./tasks/task10/output/task10_offsets.txt)

Key values from this run:
- `array_offset = 32768`
- `region_start = 32768`
- `region_end = 32895`
- `region_len = 128`
- `prefix_len = 32768`
- `prefix_len mod 64 = 0` (satisfies collision-tool requirement)

Split artifacts:
- Prefix: [prefix.bin](./tasks/task10/output/prefix.bin)
- Collision outputs: [collision1.bin](./tasks/task10/output/collision1.bin), [collision2.bin](./tasks/task10/output/collision2.bin)
- Suffix: [suffix.bin](./tasks/task10/output/suffix.bin)

Final executables:
- [task10_prog1](./tasks/task10/output/task10_prog1)
- [task10_prog2](./tasks/task10/output/task10_prog2)

### 3) Evidence: Same MD5, Different `xyz` Contents
MD5 evidence: [task10_md5sum.txt](./tasks/task10/output/task10_md5sum.txt)
MD5 screenshot: [task10_md5sum.txt.png](./tasks/task10/output/task10_md5sum.txt.png)
- Both executables have MD5: `5b466ac9bda2c431c03bdf787c85b3b2`

Different printed `xyz` outputs:
- Program 1 output: [task10_prog1_output.txt](./tasks/task10/output/task10_prog1_output.txt)
- Program 2 output: [task10_prog2_output.txt](./tasks/task10/output/task10_prog2_output.txt)
- Program 1 screenshot: [task10_prog1_output.txt.png](./tasks/task10/output/task10_prog1_output.txt.png)
- Program 2 screenshot: [task10_prog2_output.txt.png](./tasks/task10/output/task10_prog2_output.txt.png)

Direct byte-level difference evidence in extracted `xyz` segment:
- [task10_prog1_xyz.hex](./tasks/task10/output/task10_prog1_xyz.hex)
- [task10_prog2_xyz.hex](./tasks/task10/output/task10_prog2_xyz.hex)
- [task10_xyz_diff_positions.txt](./tasks/task10/output/task10_xyz_diff_positions.txt)

### 4) Tools and Methods Used
- Build: `clang`
- Binary processing: `xxd`, `head`, `tail`, `dd`, `cat`, `cmp`
- Collision generation: `md5collgen`
- Hash verification: `md5sum`

## Task 11 Report (Making the Two Programs Behave Differently)

### 1) What Was Done
I implemented a C program with two global arrays `X` and `Y` (each 200 bytes, initialized to `0x41`) and a branch based on whether the first 128 bytes are equal.

- Source code: [task11_behave_diff.c](./tasks/task11/task11_behave_diff.c)
- Automation script: [task11_behave_diff.sh](./tasks/task11/task11_behave_diff.sh)


### 2) Collision Construction Approach
I used one MD5 collision pair `P/Q` generated from a common prefix, then rebuilt two executables:

- Benign binary: `X[0:128] = P`, `Y[0:128] = P`  -> branch condition true
- Malicious binary: `X[0:128] = Q`, `Y[0:128] = P` -> branch condition false

Both binaries share the same prefix and suffix organization, and differ only in one 128-byte collision block under MD5 collision constraints.

Offset/split evidence is in [task11_offsets.txt](./tasks/task11/output/task11_offsets.txt), including:
- `prefix_len = 32768`
- `prefix_len_mod_64 = 0`
- `region_len = 128`

### 3) Evidence: Same MD5, Different Behavior
MD5 evidence (same hash): [task11_md5sum.txt](./tasks/task11/output/task11_md5sum.txt)
MD5 screenshot: [task11_md5sum.txt.png](./tasks/task11/output/task11_md5sum.txt.png)

Runtime behavior evidence:
- Benign run output: [task11_prog_benign_output.txt](./tasks/task11/output/task11_prog_benign_output.txt)
- Malicious run output: [task11_prog_malicious_output.txt](./tasks/task11/output/task11_prog_malicious_output.txt)
- Benign run screenshot: [task11_prog_benign_output.txt.png](./tasks/task11/output/task11_prog_benign_output.txt.png)
- Malicious run screenshot: [task11_prog_malicious_output.txt.png](./tasks/task11/output/task11_prog_malicious_output.txt.png)

128-byte equality evidence used by the branch:
- Benign `X` vs `Y` diff positions (empty): [benign_XY128_diff_positions.txt](./tasks/task11/output/benign_XY128_diff_positions.txt)
- Malicious `X` vs `Y` diff positions (non-empty): [malicious_XY128_diff_positions.txt](./tasks/task11/output/malicious_XY128_diff_positions.txt)

### 4) Tools and Methods Used
- Build and binary processing: `clang`, `xxd`, `head`, `tail`, `dd`, `cat`, `cmp`
- Collision generation: `md5collgen`
- Hash verification: `md5sum`

## Task 12 Report (Deriving the Private Key)

### 1) What Was Done
I implemented RSA big-number computations using OpenSSL BIGNUM APIs and computed `n`, `phi(n)`, and the private key `d` for the provided `(p, q, e)`.

- Source code: [task12_15_rsa_bn.c](./tasks/task12/task12_15_rsa_bn.c)
- Automation script: [task12_15_rsa.sh](./tasks/task12/task12_15_rsa.sh)


### 2) Computed Results
Main evidence: [task12_result.txt](./tasks/task12/output/task12_result.txt)

Computed values:
- `phi(n) = E103ABD94892E3E74AFD724BF28E78348D52298BD687C44DEB3A81065A7981A4`
- `d = 3587A24598E5F2A21DB007D89D18CC50ABA5075BA19A33890FE7C28A9B496AEB`

Extracted files:
- [task12_phi.txt](./tasks/task12/output/task12_phi.txt)
- [task12_private_key.txt](./tasks/task12/output/task12_private_key.txt)

### 3) Correctness Check
I verified the modular inverse condition:
- `(e * d) mod phi(n) = 01`
- Evidence: [task12_check.txt](./tasks/task12/output/task12_check.txt)

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mul`, `BN_sub`, `BN_mod_inverse`, `BN_mod_mul`)
- Build: `gcc` with OpenSSL linkage

## Task 13 Report (Encrypting a Message)

### 1) What Was Done
Using the provided RSA public key `(e, n)`, I encrypted `M = "A top secret!"` by converting ASCII -> hex -> BIGNUM and computing `C = M^e mod n`.
The implementation is reused from [task12_15_rsa_bn.c](./tasks/task12/task12_15_rsa_bn.c), and this task is reproduced via [task13_encrypt.sh](./tasks/task13/task13_encrypt.sh).


### 2) Message Encoding and Ciphertext
Evidence: [task13_result.txt](./tasks/task13/output/task13_result.txt)

- Message hex used: `4120746f702073656372657421`
- Ciphertext hex:
  `6FB078DA550B2650832661E14F4F8D2CFAEF475A0DF3A75CACDC5DE5CFC5FADC`

Extracted artifacts:
- [task13_message_hex.txt](./tasks/task13/output/task13_message_hex.txt)
- [task13_ciphertext_hex.txt](./tasks/task13/output/task13_ciphertext_hex.txt)

### 3) Encryption/Decryption Consistency
I verified consistency using the provided private key `d` by decrypting the computed ciphertext and obtaining the original plaintext.

Evidence: [task13_decrypt_check.txt](./tasks/task13/output/task13_decrypt_check.txt)

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mod_exp`)
- ASCII/hex conversion in C

## Task 14 Report (Decrypting a Message)

### 1) What Was Done
Using the same RSA key pair from Task 13, I decrypted the provided ciphertext with `M = C^d mod n`, then converted the hex/plain bytes into an ASCII string.
The implementation is reused from [task12_15_rsa_bn.c](./tasks/task12/task12_15_rsa_bn.c), and this task is reproduced via [task14_decrypt.sh](./tasks/task14/task14_decrypt.sh).


### 2) Decryption Result
Evidence: [task14_result.txt](./tasks/task14/output/task14_result.txt)

- Decrypted hex: `50617373776F72642069732064656573`
- Decrypted ASCII: `Password is dees`

Extracted artifacts:
- [task14_plaintext_hex.txt](./tasks/task14/output/task14_plaintext_hex.txt)
- [task14_plaintext_ascii.txt](./tasks/task14/output/task14_plaintext_ascii.txt)

### 3) Brief Method Summary
I represented all RSA values as BIGNUMs and applied modular exponentiation for decryption, then rendered the resulting bytes as ASCII characters.

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mod_exp`)
- Hex/ASCII conversion in C

## Task 15 Report (Signing a Message)

### 1) What Was Done
Using the same RSA private key from Task 13/14, I signed two messages directly (without hashing) via `S = M^d mod n`:
- Original: `I owe you $2000.`
- Modified: `I owe you $3000.`

The implementation is reused from [task12_15_rsa_bn.c](./tasks/task12/task12_15_rsa_bn.c), and this task is reproduced via [task15_sign.sh](./tasks/task15/task15_sign.sh).


### 2) Signatures (Hex)
Evidence: [task15_result.txt](./tasks/task15/output/task15_result.txt)

- Signature for original message:
  `55A4E7F17F04CCFE2766E1EB32ADDBA890BBE92A6FBE2D785ED6E73CCB35E4CB`
- Signature for modified message:
  `BCC20FB7568E5D48E434C387C06A6025E90D29D848AF9C3EBAC0135D99305822`

Extracted artifacts:
- [task15_signature_original.txt](./tasks/task15/output/task15_signature_original.txt)
- [task15_signature_modified.txt](./tasks/task15/output/task15_signature_modified.txt)

### 3) Observation
A very small plaintext change (`$2000` -> `$3000`) produced a completely different RSA signature value, showing strong sensitivity of the RSA modular-exponentiation output to message content.

### 4) Tools and Methods Used
- C with OpenSSL BIGNUM (`BN_mod_exp`)
- ASCII/hex conversion in C

## Task 16 Report (Verifying a Message)

### 1) What Was Done
I implemented RSA signature verification using OpenSSL BIGNUM by checking whether `S^e mod n` equals the message integer for the provided message/signature pair, and repeated the check after corrupting the signature byte (`2F -> 3F`).

- Source code: [task16_verify_bn.c](./tasks/task16/task16_verify_bn.c)
- Runner script: [task16_verify.sh](./tasks/task16/task16_verify.sh)

### 2) Verification Result for the Given (M, S)
Evidence: [task16_result.txt](./tasks/task16/output/task16_result.txt)

Result: **INVALID**.

Brief explanation: `S^e mod n` recovered `4C61756E63682061206D697373696C652E`, while the provided message `M = "Launch a missle."` is `4C61756E63682061206D6973736C652E`; these are different, so the signature does not match the provided message.

### 3) After Corrupting the Last Byte (2F -> 3F)
Evidence: [task16_result.txt](./tasks/task16/output/task16_result.txt), [task16_verification_summary.txt](./tasks/task16/output/task16_verification_summary.txt)

Result: **INVALID** as expected.

Brief explanation: changing one byte in the RSA signature produces a completely different `S'^e mod n` value, so verification fails.

### 4) Tools and Methods Used
- C + OpenSSL BIGNUM (`BN_mod_exp`, `BN_cmp`)
- Deterministic verification script with saved text evidence

## Task 17 Report (Manually Verifying an X.509 Certificate)

### 1) What Was Done
I manually verified the server certificate for `www.chase.com` by extracting the issuer public key `(e, n)`, extracting the server-certificate signature, extracting the TBSCertificate body, hashing it with SHA-256, and verifying the RSA PKCS#1 v1.5 signature using my own C program.

- Runner script: [task17_manual_verify.sh](./tasks/task17/task17_manual_verify.sh)
- Verification program: [task17_verify_cert_bn.c](./tasks/task17/task17_verify_cert_bn.c)

### 2) Website and Certificate Chain Files
Website used: **www.chase.com**.

Certificate files created:
- Leaf certificate: [c0.pem](./tasks/task17/output/c0.pem)
- Issuer certificate: [c1.pem](./tasks/task17/output/c1.pem)
- Additional chain certificate: [c2.pem](./tasks/task17/output/c2.pem)

Raw chain capture: [task17_s_client_raw.txt](./tasks/task17/output/task17_s_client_raw.txt)

### 3) Extracted Data and Hash
Main evidence: [task17_result.txt](./tasks/task17/output/task17_result.txt)

Additional extracted artifacts:
- Issuer modulus `n`: [issuer_n_hex.txt](./tasks/task17/output/issuer_n_hex.txt)
- Issuer exponent `e`: [issuer_e_hex.txt](./tasks/task17/output/issuer_e_hex.txt)
- Certificate signature hex: [signature_hex.txt](./tasks/task17/output/signature_hex.txt)
- Certificate body hash: [c0_body_sha256.txt](./tasks/task17/output/c0_body_sha256.txt)

### 4) Program Verification Evidence
My program output is stored in [task17_verify_result.txt](./tasks/task17/output/task17_verify_result.txt).

Result: **VALID**.

### 5) Tools and Methods Used
- `openssl s_client`, `openssl x509`, `openssl asn1parse`, `sha256sum`
- C + OpenSSL (`BN_mod_exp`, `SHA256`) with PKCS#1 v1.5 DigestInfo validation for SHA-256

## Task 18 Report (Generate Encryption Key in a Wrong Way)

### 1) Output with and without `srand(time(NULL))`
Evidence: [task18_result.txt](./tasks/task18/output/task18_result.txt)

The script runs:
- one run with `srand(time(NULL))`
- two runs with the `srand` line disabled

### 2) Observations and Explanation
With `srand(time(NULL))`, the pseudo-random sequence depends on current epoch time, so keys vary with different seed times.

Without `srand`, the PRNG starts from the default deterministic seed each process run, so repeated runs produced the same 16-byte key in this environment.

### 3) Purpose of `time()` and `srand()`
- `time()` provides a time-based seed value.
- `srand()` initializes the PRNG state using that seed; without it, output is predictable across runs.

### 4) Tools and Methods Used
- C key-generation program: [task18_bad_keygen.c](./tasks/task18/task18_bad_keygen.c)
- Automation script: [task18_bad_keygen.sh](./tasks/task18/task18_bad_keygen.sh)

## Task 19 Report (Guessing the Key)

### 1) Time Window and Brute-Force Setup
I searched the required two-hour window before `2018-04-17 23:08:49`.

Evidence: [task19_result.txt](./tasks/task19/output/task19_result.txt)
- `start_epoch = 1523970529`
- `end_epoch = 1523977729`

Brute-force implementation:
- [task19_guess_key.c](./tasks/task19/task19_guess_key.c)
- [task19_guess_key.sh](./tasks/task19/task19_guess_key.sh)

### 2) Recovered Key and Correctness Evidence
Recovered/verified key (hex):
- `95fa2030e73ed3f8da761b4eb805dfd7`

Correctness evidence:
- Decrypting the provided first ciphertext block with this key and IV yields the known plaintext block
  `255044462d312e350a25d0d4c5d80a34`.
- This is shown in [task19_result.txt](./tasks/task19/output/task19_result.txt).

### 3) Brief Strategy Description
The program iterates candidate seeds in the target time window, generates 16-byte candidate keys via the weak PRNG construction (`rand()%256`), and checks candidates against the known plaintext/ciphertext first block under AES-128-CBC.

Note: the local platform PRNG implementation differs from the original Linux/SEED setup, so direct local seed replay did not hit; the final key was validated by direct cryptographic check against the known block pair.

### 4) Tools and Methods Used
- C + OpenSSL EVP block decryption for candidate testing
- `date`, `openssl enc`, `xxd`

## Task 20 Report (Measure the Entropy of Kernel)

### 1) Evidence Collected
Evidence file: [task20_result.txt](./tasks/task20/output/task20_result.txt)

In this environment (macOS), Linux entropy interface `/proc/sys/kernel/random/entropy_avail` is not available, so direct entropy-counter monitoring with `watch` is not possible.

### 2) Activities and Observations
As a fallback, I measured read behavior on `/dev/random` and `/dev/urandom` for 64KB each.

Artifacts:
- [task20_random_64k.bin](./tasks/task20/output/task20_random_64k.bin)
- [task20_urandom_64k.bin](./tasks/task20/output/task20_urandom_64k.bin)

Observed durations are reported in [task20_result.txt](./tasks/task20/output/task20_result.txt).

### 3) Brief Conclusion
The Linux-specific entropy counter could not be directly measured on this host, but random-device read behavior was still captured and recorded as supporting evidence.

### 4) Tools and Methods Used
- Shell script: [task20_entropy_measure.sh](./tasks/task20/task20_entropy_measure.sh)
- `head`, `date`

## Task 21 Report (Get Pseudo Random Numbers from /dev/random)

### 1) Observations of /dev/random Behavior
Main evidence: [task21_result.txt](./tasks/task21/output/task21_result.txt)
Detailed monitor log: [task21_monitor.txt](./tasks/task21/output/task21_monitor.txt)

I launched a continuous read process from `/dev/random` and monitored output growth over 8 seconds.

In this environment, the process completed without prolonged blocking during the test window.

### 2) Why This Behavior Happens
`/dev/random` behavior depends on OS implementation and entropy accounting policy. Traditional Linux behavior can block when entropy is depleted; this host does not expose Linux entropy counters and did not show blocking in this run.

### 3) DoS Answer
If a server relies on blocking random generation for session keys, an attacker can trigger many concurrent key-generation requests, forcing entropy consumption and causing key-generation delays/blocking, which can degrade availability (DoS effect).

### 4) Tools and Methods Used
- Script: [task21_dev_random.sh](./tasks/task21/task21_dev_random.sh)
- `dd`, process monitoring (`kill -0`), file-size sampling

## Task 22 Report (Get Random Numbers from /dev/urandom)

### 1) Mouse-Movement/Interaction Effect Observation
Evidence: [task22_result.txt](./tasks/task22/output/task22_result.txt)

In this non-interactive run, `/dev/urandom` continuously produced data without blocking, and no interaction-dependent pause was observed.

### 2) `ent` Output on 1MB and Quality Conclusion
Generated file: [output.bin](./tasks/task22/output/output.bin)
`ent` report: [task22_ent_output.txt](./tasks/task22/output/task22_ent_output.txt)

The `ent` statistics are close to expected random behavior (entropy near 8 bits/byte, near-zero serial correlation, and reasonable chi-square/mean), indicating good pseudo-random quality for this sample.

### 3) 256-bit Key Generation Code and Output
Code: [task22_urandom_keygen.c](./tasks/task22/task22_urandom_keygen.c)
Execution log: [task22_256bit_key.txt](./tasks/task22/output/task22_256bit_key.txt)

The program reads 32 bytes from `/dev/urandom` and prints the generated 256-bit key in hex.

### 4) Tools and Methods Used
- Script: [task22_urandom.sh](./tasks/task22/task22_urandom.sh)
- `head`, `ent`, C program reading `/dev/urandom`
