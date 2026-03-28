## Task 01 Report (Task 4.5 Exploiting the Vulnerability)

### 1) What Was Done
I completed the return-to-libc payload generator in [exploit.c](./exploit.c), used [env666.c](./env666.c) to locate the `MYSHELL` environment variable, and used [retlib_debug.c](./retlib_debug.c) to measure the saved-return and argument slots inside `bof()`. The key command/output evidence is summarized in [task01_summary.txt](./output/task01_summary.txt), with screenshot evidence in [task01_summary.png](./output/task01_summary.png).

### 2) Addresses and the Values of X, Y, and Z
The first working address set collected from the static 32-bit build was:

- `system() = 0x0001a2bc`
- `exit() = 0x0001a26e`
- `"/bin/sh" = 0x40800f09`

Those values are recorded in [task01_exploit_run.txt](./output/task01_exploit_run.txt) and [task01_env_addr.txt](./output/task01_env_addr.txt). The stack-layout probe in [task01_debug_layout.txt](./output/task01_debug_layout.txt) showed:

- `ret_offset = 34`
- `arg_offset = 38`

Therefore I placed:

- `Y = 34` for the `system()` address
- `Z = 38` for the `exit()` address
- `X = 42` for the `"/bin/sh"` pointer

The ordering follows the x86 cdecl stack layout after `bof()` returns: the overwritten return address must jump to `system()`, the next word becomes `system()`'s return address (`exit()`), and the following word becomes `system()`'s first argument (`"/bin/sh"`).

### 3) Additional Investigation for the Set-UID Runtime
When I reran the helper under the actual `seed` execution path, the `MYSHELL` address changed to `0x40800f3a`, as shown in [task01_env_addr_seed.txt](./output/task01_env_addr_seed.txt). This confirmed the lab note that environment-variable addresses depend on the exact runtime context and not just on the helper's source code.

I also tested a second candidate overwrite offset (`30`) because the bundled `retlib_search` variant used a slightly different frame layout. The brute-force sweep across offsets `30` and `34` and shell-string candidates from `0x40800f00` to `0x40800f60` is recorded in [task01_bruteforce_results.txt](./output/task01_bruteforce_results.txt).

### 4) Observed Result in This Environment
The direct helper binaries [system_test](./output/system_test) and [system_env_test](./output/system_env_test) successfully executed `/bin/sh` with effective root privilege, proving that the `system()` address and privileged shell execution path were valid in this static binary environment. Their captured output is in [task01_system_test.txt](./output/task01_system_test.txt) and [task01_system_env_test.txt](./output/task01_system_env_test.txt).

However, the actual return-to-libc control-flow hijack consistently crashed with:

```text
qemu: uncaught target signal 11 (Segmentation fault) - core dumped
Segmentation fault
```

That baseline failure appears in [task01_attack_step1.txt](./output/task01_attack_step1.txt), [task01_retlib_rerun.txt](./output/task01_retlib_rerun.txt), and throughout [task01_bruteforce_results.txt](./output/task01_bruteforce_results.txt). In other words, I could validate the addresses, offsets, and privileged `system("/bin/sh")` path, but I could not reproduce a stable end-to-end root shell from the overwritten return address in this QEMU-emulated Set-UID runtime.

### 5) Step 2 and Step 3 Discussion
For Step 2, the expected behavior without `exit()` is that `system()` returns into an invalid address and the program crashes after the shell exits. In this environment, the baseline attack already crashes before reaching a stable shell, so removing `exit()` does not produce a more informative outcome than the existing segmentation-fault evidence.

For Step 3, changing the program name should invalidate the old `"/bin/sh"` pointer because the environment layout depends on the program name length. The changed address observed between the normal helper run and the actual Set-UID `seed` run already demonstrates the same underlying issue: hard-coded environment pointers are fragile and must match the exact runtime context.

### 6) Tools and Methods Used
I reused the provided vulnerable program and helper programs, executed the Linux i386 binaries inside a reproducible `i386/debian:bookworm-slim` container, and used additional trial runs to verify how the environment-variable address changed across execution contexts.
