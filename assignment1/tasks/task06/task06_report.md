## Task 06 Report (Initial Vector, IV)

### 1) What Was Done
I completed Task 6.1 (IV uniqueness), Task 6.2 (OFB known-plaintext recovery), and Task 6.3 (predictable-IV chosen-plaintext attack on CBC).

### 2) Task 6.1: IV Uniqueness Observation
Evidence: [task61_observation.txt](./output/task61_observation.txt)

First-block ciphertexts for the same plaintext under AES-128-CBC:
- IV1 first run: `c40201ad66afcc48f86c14bbb9d9d4d8`
- IV2 run: `74112c76433b7e6847bb4d62f5071807`
- IV1 second run: `c40201ad66afcc48f86c14bbb9d9d4d8`

Observation: Reusing the same IV with the same key/plaintext gives the same first ciphertext block, while changing IV changes it. This is why IV uniqueness is required.

### 3) Task 6.2: Recovering P2 in OFB
Evidence: [task62_recovery.txt](./output/task62_recovery.txt)

Recovered plaintext:
- `P2 = Order: Launch a missile!`

Method (brief): In OFB, ciphertext is plaintext XOR keystream. With reused IV, the same keystream is reused, so `P2 = C2 XOR C1 XOR P1`.

CFB answer: only the first plaintext block of `P2` can be directly revealed in this setting; later blocks depend on unknown `E_K(C2_{i-1})`.

### 4) Task 6.3: Predictable-IV Chosen-Plaintext Attack (CBC)
Evidence: [task63_attack_result.txt](./output/task63_attack_result.txt)

Chosen plaintexts and oracle ciphertexts:
- Yes-test `P2` hex: `5965730d0d0d0d0d0d0d0d0d0d0d0d0c`
- Oracle `C2` (Yes-test): `bef65565572ccee2a9f9553154ed9498`
- Target `C1`: `bef65565572ccee2a9f9553154ed9498`

Since `C2 == C1` for the Yes-test, the hidden original message `P1` is inferred to be `Yes`.

### 5) Tools and Methods Used
- OpenSSL `enc` with AES-128-CBC/OFB
- XOR-based keystream recovery for OFB
- Chosen-plaintext construction for predictable-IV CBC attack
