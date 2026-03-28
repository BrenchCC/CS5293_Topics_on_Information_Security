## Task 03 Report (Task 4.7 Stack Guard Protection)

### 1) What Was Done
I rebuilt the vulnerable program from [retlib.c](../task01/retlib.c) with Stack Guard enabled and then examined both the generated machine code and the runtime behavior. The summary evidence is in [task03_summary.txt](./output/task03_summary.txt), with screenshot evidence in [task03_summary.png](./output/task03_summary.png).

### 2) Compilation Command
The protected build command I used was:

```text
zig cc -target x86-linux-musl assignment2/tasks/task4/task01/retlib.c \
    -o assignment2/tasks/task4/task03/output/retlib_stackguard \
    -DBUFSIZE=22 -fstack-protector-all -no-pie -z noexecstack
```

This intentionally omits `-fno-stack-protector`, so the compiler inserts a stack canary.

### 3) Evidence That Stack Guard Was Inserted
The disassembly of the protected binary shows the classic canary sequence in `bof()`:

- load the canary from `%gs:0x14`
- store it in the current stack frame
- compare it again before returning
- call `__stack_chk_fail_local` if the value changed

The summary output also records the presence of `__stack_chk_fail` and `__stack_chk_guard` symbols in the binary.

### 4) Runtime Observation
Running the protected binary with the same malicious `badfile` still ended with:

```text
qemu: uncaught target signal 11 (Segmentation fault) - core dumped
Segmentation fault
```

So the current emulated runtime did not surface a friendly `stack smashing detected` message. Even so, the protected build clearly contains the Stack Guard instrumentation, and that instrumentation would abort the program before returning to an attacker-controlled address once the canary mismatch is detected on a native runtime.

### 5) How Stack Guard Makes the Attack Difficult
Return-to-libc still needs to overwrite control data on the stack. Stack Guard places a canary value between the local buffer and the saved control fields. When the overflow corrupts the return address, it also corrupts the canary. Before the function returns, the canary check fails and the program terminates through `__stack_chk_fail_local`, preventing the attacker from reaching the forged `system()` return target.

### 6) Tools and Methods Used
I used `zig cc` to cross-compile a static Linux i386 binary with `-fstack-protector-all`, inspected the resulting machine code with `objdump`, and reran the malicious input inside the same reproducible i386 container workflow used for the earlier Task 4 experiments.
