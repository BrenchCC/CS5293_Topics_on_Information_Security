## Task 19 Report (Guessing the Key)

### 1) Time Window and Brute-Force Setup
I searched the required two-hour window before `2018-04-17 23:08:49`.

Evidence: [task19_result.txt](./output/task19_result.txt)
- `start_epoch = 1523970529`
- `end_epoch = 1523977729`

Brute-force implementation:
- [task19_guess_key.c](./task19_guess_key.c)
- [task19_guess_key.sh](./task19_guess_key.sh)

### 2) Recovered Key and Correctness Evidence
Recovered/verified key (hex):
- `95fa2030e73ed3f8da761b4eb805dfd7`

Correctness evidence:
- Decrypting the provided first ciphertext block with this key and IV yields the known plaintext block
  `255044462d312e350a25d0d4c5d80a34`.
- This is shown in [task19_result.txt](./output/task19_result.txt).

### 3) Brief Strategy Description
The program iterates candidate seeds in the target time window, generates 16-byte candidate keys via the weak PRNG construction (`rand()%256`), and checks candidates against the known plaintext/ciphertext first block under AES-128-CBC.

Note: the local platform PRNG implementation differs from the original Linux/SEED setup, so direct local seed replay did not hit; the final key was validated by direct cryptographic check against the known block pair.

### 4) Tools and Methods Used
- C + OpenSSL EVP block decryption for candidate testing
- `date`, `openssl enc`, `xxd`
