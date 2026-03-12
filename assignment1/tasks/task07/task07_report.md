## Task 07 Report (Programming with Crypto Library)

### 1) What Was Done
I implemented a C brute-force program using OpenSSL EVP APIs to recover the AES-128-CBC key from the provided plaintext/ciphertext/IV pair, under the rule that the key is an English word padded with `#` to 16 bytes.
The source code is [task07_bruteforce.c](./task07_bruteforce.c), and this task follows [AGENTS.md](../../../AGENTS.md).

### 2) Build and Run
Compile command (with crypto library):
- `gcc -Wall -Wextra -O2 -o task07_bruteforce task07_bruteforce.c $(pkg-config --cflags --libs openssl)`

Run command:
- `./task07_bruteforce`

Program output evidence: [task07_bruteforce_result.txt](./output/task07_bruteforce_result.txt)

### 3) Recovered Key and Correctness Evidence
Recovered dictionary word key:
- `Syracuse`

Recovered 128-bit padded key:
- ASCII: `Syracuse########`
- Hex: `53797261637573652323232323232323`

Correctness evidence:
- Program decrypted the ciphertext to exactly `This is a top secret.`

### 4) Dictionary Source/Strategy
I used the provided word list [words.txt](../../assignment1-supplymentary/words.txt). The strategy was exhaustive dictionary search: for each word shorter than 16 bytes, pad with `#` to 16 bytes, decrypt with AES-128-CBC, and compare against the known target plaintext.

### 5) Tools and Methods Used
- C + OpenSSL EVP (`EVP_DecryptInit_ex`, `EVP_DecryptUpdate`, `EVP_DecryptFinal_ex`)
- `gcc` with OpenSSL crypto linkage
- Dictionary-based brute-force key search
