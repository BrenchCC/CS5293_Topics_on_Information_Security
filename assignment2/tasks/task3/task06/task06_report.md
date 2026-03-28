## Task 06 Report (Task 3.8 Non-executable Stack Protection)

### 1) What Was Done
I recompiled the vulnerable program without patching the executable-stack flag, keeping the stack non-executable, and reran the same exploit from Task 3.4. The summary is stored in [task06_summary.txt](./output/task06_summary.txt), with screenshot evidence in [task06_summary.png](./output/task06_summary.png).

### 2) Compilation Command
The command used for the protected build was:

```text
zig cc -target x86-linux-musl stack.c -o stack_noexec -DBUFSIZE=24 -fno-stack-protector -fno-omit-frame-pointer
```

Unlike the earlier vulnerable binary, this build was not passed through the executable-stack patching step, so the stack remained non-executable.

### 3) Attack Result
The attack no longer produced a shell. Instead, execution crashed with:

- `qemu: uncaught target signal 11 (Segmentation fault) - core dumped`
- `Segmentation fault`

### 4) Why the Shellcode Cannot Execute
The injected payload still reaches the stack, but the CPU is not allowed to fetch and execute instructions from non-executable stack memory. When the overwritten return address transfers control to the stack buffer, execution faults immediately rather than running the shellcode.

### 5) Protection Explanation
Non-executable stack protection does not prevent the overwrite itself; it prevents code execution from stack pages. This blocks classic stack-shellcode attacks, although it does not stop other control-flow hijacking techniques such as return-to-libc or ROP.
