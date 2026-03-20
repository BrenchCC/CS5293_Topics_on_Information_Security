## Task 05 Report (Error Propagation: Corrupted Ciphertext)

### 1) What Was Done
I created a plaintext file longer than 1000 bytes, encrypted it with AES-128 in ECB/CBC/CFB/OFB, flipped one bit in ciphertext byte #55, and decrypted with the correct key/IV.

### 2) Prediction Before Running the Experiment
Prediction evidence: [prediction.txt](./output/prediction.txt)

- ECB: one full plaintext block is corrupted.
- CBC: current block corrupted + one bit flip in next block.
- CFB (128-bit): one bit flip in current block + next block corruption.
- OFB: only the corresponding bit flips, no further propagation.

### 3) Experimental Evidence
Main summary: [corruption_summary.txt](./output/corruption_summary.txt)
Screenshot-style snapshot: [task05_evidence_snapshot.txt.png](./output/task05_evidence_snapshot.txt.png)

Observed:
- ECB: `different_bytes=16`, first diff at 49, last diff at 64.
- CBC: `different_bytes=17`, first diff at 49, last diff at 71.
- CFB: `different_bytes=17`, first diff at 55, last diff at 80.
- OFB: `different_bytes=1`, only at position 55.

Hex snippets around the affected region:
- [snippet_ecb.txt](./output/snippet_ecb.txt)
- [snippet_cbc.txt](./output/snippet_cbc.txt)
- [snippet_cfb.txt](./output/snippet_cfb.txt)
- [snippet_ofb.txt](./output/snippet_ofb.txt)

### 4) Comparison: Prediction vs. Observation
The results match the prediction pattern for all four modes. OFB showed strictly local bit-flip behavior, while CBC/CFB showed additional propagation due to block chaining/feedback dependencies, and ECB isolated corruption to one block.

### 5) Tools and Methods Used
- OpenSSL `enc` with AES-128 ECB/CBC/CFB/OFB
- One-bit ciphertext corruption via binary byte edit script
- `cmp -l` and `xxd` for location and byte-level evidence
