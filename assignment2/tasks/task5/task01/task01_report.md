## Task 01 Report (Task 5.1 Crash the Program)

### 1) What Was Done
I reconstructed the vulnerable program in [vul_prog.c](./vul_prog.c), compiled it as a Linux i386 binary, and used a stack-probe run recorded in [task01_stack_probe.txt](./output/task01_stack_probe.txt) to locate the decimal integer input on the `printf` argument list. The final crash evidence is summarized in [task01_summary.txt](./output/task01_summary.txt), with screenshot evidence in [task01_summary.png](./output/task01_summary.png).

### 2) Input String Used to Crash the Program
The exact input is stored in [task01_input.txt](./task01_input.txt):

```text
1
%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%s
```

### 3) Why It Crashes
The stack probe showed that the decimal integer input becomes the 21st argument consumed by `printf(user_input)`. The first 20 `%x` specifiers consume the earlier stack words, and the final `%s` treats the 21st argument as a pointer to a string.

By entering decimal integer `1`, I made the 21st argument equal to address `0x00000001`. When `printf` reached `%s`, it tried to read bytes from that invalid address and crashed with a segmentation fault.

### 4) Observed Result
The captured output in [task01_run.txt](./output/task01_run.txt) shows the crash:

```text
The variable secret's address is 0x40800d38 (on stack)
qemu: uncaught target signal 11 (Segmentation fault) - core dumped
```

### 5) Tools and Methods Used
I used the reconstructed vulnerable program, a reproducible Linux i386 Docker container, and one stack-probe run to identify the correct argument position before constructing the crashing payload.
