## Task 22 Report (Get Random Numbers from /dev/urandom)

### 1) Mouse-Movement/Interaction Effect Observation
Evidence: [task22_result.txt](./output/task22_result.txt)

In this non-interactive run, `/dev/urandom` continuously produced data without blocking, and no interaction-dependent pause was observed.

### 2) `ent` Output on 1MB and Quality Conclusion
Generated file: [output.bin](./output/output.bin)
`ent` report: [task22_ent_output.txt](./output/task22_ent_output.txt)

The `ent` statistics are close to expected random behavior (entropy near 8 bits/byte, near-zero serial correlation, and reasonable chi-square/mean), indicating good pseudo-random quality for this sample.

### 3) 256-bit Key Generation Code and Output
Code: [task22_urandom_keygen.c](./task22_urandom_keygen.c)
Execution log: [task22_256bit_key.txt](./output/task22_256bit_key.txt)

The program reads 32 bytes from `/dev/urandom` and prints the generated 256-bit key in hex.

### 4) Tools and Methods Used
- Script: [task22_urandom.sh](./task22_urandom.sh)
- `head`, `ent`, C program reading `/dev/urandom`
