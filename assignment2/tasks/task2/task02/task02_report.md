## Task 02 Report (Environment Variable and Set-UID Programs)

### 1) What Was Done
I compiled the Set-UID environment-dumping program from [setuidenv.c](./setuidenv.c), changed the binary ownership to `root`, enabled the Set-UID bit, and executed it from the `seed` account after exporting `PATH`, `LD_LIBRARY_PATH`, and `ANY_NAME`.

The full raw output is stored in [task02_setuid_env.txt](./output/task02_setuid_env.txt). A focused summary of the relevant variables is in [task02_summary.txt](./output/task02_summary.txt), with screenshot evidence in [task02_summary.png](./output/task02_summary.png).

### 2) Which Variables Were Inherited
Observed results from the Set-UID child process:

- `PATH` was inherited.
- `ANY_NAME` was inherited.
- `LD_LIBRARY_PATH` was not inherited.

The filtered evidence file [task02_filtered_vars.txt](./output/task02_filtered_vars.txt) shows `PATH` and `ANY_NAME`, but no `LD_LIBRARY_PATH`.

### 3) Surprise and Explanation
The interesting result is that a user-defined variable such as `ANY_NAME` still reaches the Set-UID child process, while `LD_LIBRARY_PATH` does not. This is expected behavior on Linux because dynamic-loader-related variables are sanitized in secure-execution mode to prevent users from hijacking privileged programs through custom libraries.

### 4) Tools and Methods Used
Compilation and execution were automated in [run_task2_docker.sh](../../../tools/run_task2_docker.sh). Screenshot rendering was produced by [render_terminal_capture.sh](../../../tools/render_terminal_capture.sh).
