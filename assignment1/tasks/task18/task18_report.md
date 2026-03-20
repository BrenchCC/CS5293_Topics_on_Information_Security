## Task 18 Report (Generate Encryption Key in a Wrong Way)

### 1) Output with and without `srand(time(NULL))`
Evidence: [task18_result.txt](./output/task18_result.txt)

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
- C key-generation program: [task18_bad_keygen.c](./task18_bad_keygen.c)
- Automation script: [task18_bad_keygen.sh](./task18_bad_keygen.sh)
