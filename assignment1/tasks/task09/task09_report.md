## Task 09 Report (Understanding MD5’s Property)

### 1) Experiment Design
I selected the colliding pair from Task 08 as:
- `M = out1_64.bin`
- `N = out2_64.bin`

Then I created a common suffix file `T` and appended it to both files:
- `M || T`
- `N || T`

Automation script: [task09_md5_property.sh](./task09_md5_property.sh)

This task follows [AGENTS.md](../../../AGENTS.md).

### 2) Command Evidence
Main evidence file: [task09_md5_property.txt](./output/task09_md5_property.txt)

Observed results:
- `MD5(M) = MD5(N) = 7cc4cac2bcc2d538e6b7fa0b20858d78`
- `MD5(M || T) = MD5(N || T) = 2fc5662f9d149f666a8566446f847f37`

Supplementary files:
- Suffix file: [suffix_T.bin](./output/suffix_T.bin)
- Generated files: [M_plus_T.bin](./output/M_plus_T.bin), [N_plus_T.bin](./output/N_plus_T.bin)
- Size summary: [task09_sizes.txt](./output/task09_sizes.txt)

### 3) Brief Explanation
MD5 is iterative over 64-byte blocks. If two inputs reach the same intermediate hash state at the end (`MD5(M) = MD5(N)`), appending the same suffix `T` feeds identical later blocks into identical internal states, so the final hashes remain equal.

### 4) Tools and Methods Used
- File concatenation: `cat`
- Hash verification: `md5sum`
