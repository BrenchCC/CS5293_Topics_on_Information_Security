## Task 01 Report (Task 3.2 Running Shellcode)

### 1) What Was Done
I compiled [call_shellcode.c](./call_shellcode.c) as a 32-bit Linux binary, patched the executable-stack flag, and executed it from the `seed` account. The raw command/output summary is stored in [task01_summary.txt](./output/task01_summary.txt), with screenshot evidence in [task01_summary.png](./output/task01_summary.png).

### 2) Whether a Shell Was Invoked
Yes. The injected shellcode successfully invoked `/bin/sh`, and the shell accepted commands from standard input. The output shows `seed` after `whoami`, confirming that the shell was actually running.

### 3) Brief Observation
This experiment confirms that the provided shellcode is valid and executable when the stack is marked executable. It also establishes the payload that will later be placed inside `badfile` for the buffer-overflow attack.

### 4) Tools and Methods Used
I used `zig cc -target x86-linux-musl` for 32-bit compilation and [patch_execstack.pl](../../../tools/patch_execstack.pl) to mark the stack executable.
