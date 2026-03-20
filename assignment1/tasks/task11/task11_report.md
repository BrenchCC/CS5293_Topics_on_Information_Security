## Task 11 Report (Making the Two Programs Behave Differently)

### 1) What Was Done
I implemented a C program with two global arrays `X` and `Y` (each 200 bytes, initialized to `0x41`) and a branch based on whether the first 128 bytes are equal.

- Source code: [task11_behave_diff.c](./task11_behave_diff.c)
- Automation script: [task11_behave_diff.sh](./task11_behave_diff.sh)


### 2) Collision Construction Approach
I used one MD5 collision pair `P/Q` generated from a common prefix, then rebuilt two executables:

- Benign binary: `X[0:128] = P`, `Y[0:128] = P`  -> branch condition true
- Malicious binary: `X[0:128] = Q`, `Y[0:128] = P` -> branch condition false

Both binaries share the same prefix and suffix organization, and differ only in one 128-byte collision block under MD5 collision constraints.

Offset/split evidence is in [task11_offsets.txt](./output/task11_offsets.txt), including:
- `prefix_len = 32768`
- `prefix_len_mod_64 = 0`
- `region_len = 128`

### 3) Evidence: Same MD5, Different Behavior
MD5 evidence (same hash): [task11_md5sum.txt](./output/task11_md5sum.txt)
MD5 screenshot: [task11_md5sum.txt.png](./output/task11_md5sum.txt.png)

Runtime behavior evidence:
- Benign run output: [task11_prog_benign_output.txt](./output/task11_prog_benign_output.txt)
- Malicious run output: [task11_prog_malicious_output.txt](./output/task11_prog_malicious_output.txt)
- Benign run screenshot: [task11_prog_benign_output.txt.png](./output/task11_prog_benign_output.txt.png)
- Malicious run screenshot: [task11_prog_malicious_output.txt.png](./output/task11_prog_malicious_output.txt.png)

128-byte equality evidence used by the branch:
- Benign `X` vs `Y` diff positions (empty): [benign_XY128_diff_positions.txt](./output/benign_XY128_diff_positions.txt)
- Malicious `X` vs `Y` diff positions (non-empty): [malicious_XY128_diff_positions.txt](./output/malicious_XY128_diff_positions.txt)

### 4) Tools and Methods Used
- Build and binary processing: `clang`, `xxd`, `head`, `tail`, `dd`, `cat`, `cmp`
- Collision generation: `md5collgen`
- Hash verification: `md5sum`
