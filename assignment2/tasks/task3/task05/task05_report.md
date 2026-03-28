## Task 05 Report (Task 3.7 Stack Guard Protection)

### 1) What Was Done
I investigated Stack Guard in two build paths:

- `zig cc -target x86-linux-musl ... -fstack-protector-all`
- `zig cc -target x86-linux-gnu ... -fstack-protector-all`

The summary evidence is in [task05_summary.txt](./output/task05_summary.txt), with screenshot evidence in [task05_summary.png](./output/task05_summary.png).

### 2) Compilation Command
The intended protected build command was:

```text
zig cc -target x86-linux-gnu stack.c -o stack -DBUFSIZE=24 -fno-omit-frame-pointer -fstack-protector-all
```

This is the equivalent of recompiling the vulnerable program without `-fno-stack-protector` and explicitly enabling canary insertion in the current toolchain.

### 3) Observed Limitation in This Environment
The `x86-linux-musl` build path did not emit a canary check inside `bof()`, even when `-fstack-protector-all` was supplied, so it could not demonstrate the expected runtime failure.

The `x86-linux-gnu` build path did emit the Stack Guard logic, including a canary load from `%gs:0x14` and a call to `__stack_chk_fail` in the function epilogue. However, this runtime path could not be executed in the container because the required 32-bit glibc userspace was unavailable and package installation in the container remained blocked by the environment.

### 4) How Stack Guard Works
Stack Guard places a canary value between local buffers and the saved control data on the stack. When a buffer overflow overwrites past the buffer, it also corrupts the canary. Before returning, the function compares the current canary value with the original one; if they differ, execution is aborted through `__stack_chk_fail` instead of returning to an attacker-controlled address.

### 5) Evidence Collected
The attached disassembly excerpt in [task05_summary.txt](./output/task05_summary.txt) shows the canary setup and check in the `x86-linux-gnu` build. In this environment, that static evidence was the most accurate way to document Stack Guard behavior.
