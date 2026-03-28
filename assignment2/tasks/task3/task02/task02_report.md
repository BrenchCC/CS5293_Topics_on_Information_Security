## Task 02 Report (Task 3.4 Exploiting the Vulnerability)

### 1) What Was Done
I compiled the vulnerable Set-UID program from [stack.c](./stack.c), measured the runtime stack layout with [stack_debug.c](./stack_debug.c) and [stack_info.c](./stack_info.c), and completed the exploit generator in [exploit_arg.c](./exploit_arg.c). The final exploit used a NOP sled plus the provided shellcode and overwrote the saved return address in `bof()`.

The working command/output evidence is summarized in [task02_summary.txt](./output/task02_summary.txt), with screenshot evidence in [task02_summary.png](./output/task02_summary.png).

### 2) Completed Exploit Code and Solution
The exploit implementation is in [exploit_arg.c](./exploit_arg.c). It fills `badfile` with `0x90`, copies the shellcode near the end of the 517-byte input, and writes the chosen return address at the correct overwrite offset.

### 3) Return Address and Offset
The working values were:

- Return address: `0x40800b6f`
- Offset: `28`

I determined these values by first measuring the stable `str` address in `main()` and then using an `exit(42)` probe to find the exact overwrite position that redirected execution into the NOP sled. The earlier helper that reported offset `32` added an extra local variable and slightly perturbed the stack frame, so the final verified overwrite position was `28`.

### 4) Attack Result
The attack successfully produced a root shell. The captured output shows:

- `uid=0(root) gid=1000(seed) groups=1000(seed)`
- `root`

This confirms that the overflow redirected control flow into the injected shellcode and that the Set-UID root program executed the payload with effective root privilege.

### 5) Tools and Methods Used
Compilation used `zig cc -target x86-linux-musl`, the executable-stack bit was enabled with [patch_execstack.pl](../../../tools/patch_execstack.pl), and the full runtime was exercised inside the reproducible container workflow.
