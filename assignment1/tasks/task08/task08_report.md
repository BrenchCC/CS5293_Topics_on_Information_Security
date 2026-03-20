## Task 08 Report (Generating Two Different Files with the Same MD5 Hash)

### 1) What Was Done
I used `md5collgen` with two prefixes:
- A non-64-byte prefix: [prefix_non64.txt](./output/prefix_non64.txt)
- An exactly 64-byte prefix: [prefix_64.txt](./output/prefix_64.txt)


### 2) Evidence: Different Files, Same MD5
Evidence file: [task08_diff_md5.txt](./output/task08_diff_md5.txt)

Results:
- `out1_non64.bin` and `out2_non64.bin` are different (`diff` reports binary difference), but both have MD5 `88085b538d8d9e243c91fd76fcca47ff`.
- `out1_64.bin` and `out2_64.bin` are different, but both have MD5 `7cc4cac2bcc2d538e6b7fa0b20858d78`.

Size summary: [task08_sizes.txt](./output/task08_sizes.txt)

### 3) Answers to Question 1–3
Question 1 (prefix length not multiple of 64):
- Collision generation still succeeds. With a 27-byte prefix, both output files are different but share the same MD5.

Question 2 (prefix length exactly 64 bytes):
- Collision generation also succeeds. With a 64-byte prefix, outputs are different but share the same MD5.

Question 3 (are the 128 bytes completely different?):
- No. In this run, only a small subset of bytes differ in the 128-byte collision blocks.
- Exact differing positions are listed in [collision_block_diff_positions.txt](./output/collision_block_diff_positions.txt).
- Hex evidence is in [block1_64.hex](./output/block1_64.hex) and [block2_64.hex](./output/block2_64.hex).

### 4) Tools and Methods Used
- Collision generator: `md5collgen`
- Validation tools: `diff`, `md5sum`, `cmp`, `dd`, `xxd`
