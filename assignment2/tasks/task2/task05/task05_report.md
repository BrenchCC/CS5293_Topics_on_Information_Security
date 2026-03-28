## Task 05 Report (Invoking External Programs Using `system()` Versus `execve()`)

### 1) Step 1: `system()` Attack
I compiled the vulnerable wrapper [catwrapper.c](./catwrapper.c) as a root-owned Set-UID program and used the following attack input:

```text
/tmp/task25/secret.txt; echo compromised > /tmp/task25/protected.txt
```

This injected a second shell command through `system()`, so the program first printed `secret.txt` and then modified the protected file. The raw output is in [task05_system_attack.txt](./output/task05_system_attack.txt), and the post-attack file state is in [task05_file_state.txt](./output/task05_file_state.txt).

### 2) Step 2: `execve()` Re-Test
I then compiled [catwrapper_execve.c](./catwrapper_execve.c) and re-ran the exact same attack string. This time the attack failed because `execve()` treated the entire string as one filename instead of giving it to a shell.

The failure evidence is in [task05_execve_attack.txt](./output/task05_execve_attack.txt). The combined screenshot evidence is [task05_summary.png](./output/task05_summary.png).

### 3) Explanation
`system()` is vulnerable because it delegates command parsing to a shell, so shell metacharacters such as `;` and redirection operators are interpreted as separate commands. `execve()` does not invoke a shell, so no shell parsing occurs; the injected string remains plain data.

### 4) Tools and Methods Used
The binaries were built and executed with [run_task2_docker.sh](../../../tools/run_task2_docker.sh). Output rendering used [render_terminal_capture.sh](../../../tools/render_terminal_capture.sh).
