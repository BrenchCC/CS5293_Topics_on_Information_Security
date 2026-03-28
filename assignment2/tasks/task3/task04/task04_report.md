## Task 04 Report (Task 3.6 Defeating Address Randomization)

### 1) What Was Done
I repeated the Task 3.4 exploit without `setarch -R` and recorded the kernel randomization setting plus multiple runtime address samples from the Set-UID debugging binary. The summary is stored in [task04_summary.txt](./output/task04_summary.txt), with screenshot evidence in [task04_summary.png](./output/task04_summary.png).

### 2) Observed Result in This Environment
Inside the container, `/proc/sys/kernel/randomize_va_space` was already set to `2`, but the repeated runs of the Set-UID debugging binary still produced the exact same stack addresses:

- `str = 0x40800b6f`
- `buffer = 0x40800b1c`
- `ret_addr_slot = 0x40800b3c`

Because the addresses remained stable, the previous exploit still succeeded even without `setarch -R`.

### 3) Explanation
Under a normal native Linux setup, address randomization should move the stack location from run to run, making a hard-coded return address unreliable and forcing either brute force or a larger landing zone. In this specific execution environment, the combination of the static 32-bit emulation path and containerized runtime did not expose that expected address variation, so the task could not reproduce the initial attack failure described in the original lab.

### 4) Brute-Force Observation
A brute-force loop was not needed here because the attack already succeeded on the first run. The evidence therefore documents an environment-specific limitation rather than the usual ASLR defeat process.

### 5) Tools and Methods Used
I reused the working exploit from Task 3.4 and compared repeated runs of the Set-UID debugging binary to verify whether the stack addresses changed.
