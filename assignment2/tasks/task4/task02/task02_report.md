## Task 02 Report (Task 4.6 Address Randomization)

### 1) What Was Done
I kept the same return-to-libc setup from Task 4.5 and checked whether address randomization changed the runtime addresses needed by the exploit. The summary evidence is in [task02_summary.txt](./output/task02_summary.txt), with screenshot evidence in [task02_summary.png](./output/task02_summary.png).

### 2) Observed Result
Inside the Linux i386 container, `/proc/sys/kernel/randomize_va_space` was:

```text
2
```

So ASLR was nominally enabled. I then ran the helper program multiple times as both root and `seed`:

- root: `0x40800f0d` on every run
- `seed`: `0x40800f3a` on every run

The exploit itself also failed in the same way across repeated attempts:

```text
qemu: uncaught target signal 11 (Segmentation fault) - core dumped
Segmentation fault
```

### 3) Explanation
On a normal native Linux system, ASLR makes return-to-libc harder because both the `"/bin/sh"` string address and the relevant libc addresses can shift from one execution to the next. A hard-coded payload then becomes unreliable unless the attacker can leak addresses or brute-force them.

In this specific execution path, the kernel setting indicated ASLR was enabled, but the observed helper addresses remained completely stable. That means the expected randomization effect was not visible in the QEMU-emulated 32-bit runtime used here. As a result, ASLR was not the immediate reason for the exploit failure in this environment, even though it would normally be an important defense on a native system.

### 4) Tools and Methods Used
I reused the Task 4.5 binaries, checked the kernel ASLR setting inside the container, and repeated the address probe several times under both root and `seed` to determine whether the key address changed across runs.
