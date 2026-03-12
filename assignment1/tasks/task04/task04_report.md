## Task 04 Report (Padding)

### 1) What Was Done
I conducted padding experiments for AES-128 in ECB/CBC/CFB/OFB modes and then inspected PKCS padding behavior using 5-byte, 10-byte, and 16-byte plaintext files.
The automation script is [task04_padding.sh](./task04_padding.sh), and this task follows [AGENTS.md](../../../AGENTS.md).

### 2) ECB/CBC/CFB/OFB: Which Modes Use Padding?
Using a 21-byte plaintext, I compared ciphertext sizes across modes.
Evidence: [mode_padding_sizes.txt](./output/mode_padding_sizes.txt)

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
- Inputs: [f5.txt](./output/f5.txt), [f10.txt](./output/f10.txt), [f16.txt](./output/f16.txt)
- Ciphertexts: [f5.cbc.enc](./output/f5.cbc.enc), [f10.cbc.enc](./output/f10.cbc.enc), [f16.cbc.enc](./output/f16.cbc.enc)

Encrypted sizes evidence: [cbc_file_sizes.txt](./output/cbc_file_sizes.txt)
- `f5.cbc.enc`: 16 bytes
- `f10.cbc.enc`: 16 bytes
- `f16.cbc.enc`: 32 bytes

Padding-byte evidence (using `-nopad` decryption + hex view):
- Evidence file: [padding_last_block_hex.txt](./output/padding_last_block_hex.txt)
- `f5` last block: `31323334350b0b0b0b0b0b0b0b0b0b0b` (11 bytes of `0x0b`)
- `f10` last block: `31323334353637383930060606060606` (6 bytes of `0x06`)
- `f16` last block: `10101010101010101010101010101010` (full extra block of `0x10`)

### 4) Brief Summary of PKCS#5/PKCS#7 Pattern
The padding value equals the number of padding bytes added. When plaintext length is already one full block (16 bytes for AES), a full block of padding is appended (16 bytes of `0x10`).

### 5) Tools and Methods Used
- OpenSSL `enc` with AES-128 ECB/CBC/CFB/OFB
- OpenSSL `-nopad` during decryption for raw padded plaintext inspection
- `xxd` and `wc` for hex/size evidence
