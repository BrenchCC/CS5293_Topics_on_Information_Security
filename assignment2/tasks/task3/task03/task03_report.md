## Task 03 Report (Task 3.5 Defeating dash's Countermeasure)

### 1) What Was Done
I compiled two versions of the dash test program, [dash_shell_test_nosetuid.c](./dash_shell_test_nosetuid.c) and [dash_shell_test_setuid.c](./dash_shell_test_setuid.c), and ran both as Set-UID root programs while `/bin/sh` pointed back to `/bin/dash`. I then updated the exploit payload in [exploit_setuid0.c](./exploit_setuid0.c) to prepend the `setuid(0)` system call before `execve("/bin/sh", ...)`.

The collected evidence is summarized in [task03_summary.txt](./output/task03_summary.txt), with screenshot evidence in [task03_summary.png](./output/task03_summary.png).

### 2) Difference Between the Two dash Tests
When `setuid(0)` was not called, dash dropped the privilege and the shell ran as `seed`:

- `uid=1000(seed) gid=1000(seed) groups=1000(seed)`
- `seed`

When `setuid(0)` was called before `execve("/bin/sh", ...)`, dash no longer dropped the privilege:

- `uid=0(root) gid=1000(seed) groups=1000(seed)`
- `root`

This demonstrates exactly how dash's countermeasure works: it compares the real and effective IDs, and calling `setuid(0)` makes both root before dash starts.

### 3) Updated Exploit
The updated exploit is in [exploit_setuid0.c](./exploit_setuid0.c). It uses the shellcode sequence that invokes `setuid(0)` first and then executes `/bin/sh`.

The working values remained:

- Return address: `0x40800b6f`
- Offset: `28`

### 4) Attack Result
With `/bin/sh` linked to `/bin/dash`, the updated payload successfully obtained a root shell. The captured output shows both `uid=0(root)` and `root`, confirming that the dash privilege-dropping countermeasure was defeated.

### 5) Tools and Methods Used
I reused the same vulnerable program from Task 3.4, replaced only the payload, and verified the behavior difference with two dedicated Set-UID dash test binaries before launching the final exploit.
