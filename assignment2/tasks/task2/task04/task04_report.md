## Task 04 Report (The `LD_PRELOAD` Environment Variable and Set-UID Programs)

### 1) What Was Done
I built the preload library [mylib.c](./mylib.c) as `libmylib.so.1.0.1`, built [myprog.c](./myprog.c), and executed `myprog` under the four conditions required by the assignment.

The four raw outputs are:

- [task04_case1_regular.txt](./output/task04_case1_regular.txt)
- [task04_case2_setuid_root_normal_user.txt](./output/task04_case2_setuid_root_normal_user.txt)
- [task04_case3_setuid_root_root_user.txt](./output/task04_case3_setuid_root_root_user.txt)
- [task04_case4_setuid_user1_other_user.txt](./output/task04_case4_setuid_user1_other_user.txt)

The combined summary screenshot is [task04_summary.png](./output/task04_summary.png), and the experiment notes are in [task04_experiment_notes.txt](./output/task04_experiment_notes.txt).

### 2) Results for the Four Conditions
Observed behavior:

1. Regular program run by `seed`: `I am not sleeping!`
2. Set-UID root program run by `seed`: no override output
3. Set-UID root program run by `root`: `I am not sleeping!`
4. Set-UID `user1` program run by `seed`: no override output

### 3) Experiment Design and Explanation
The experiment kept the same binary and library while changing only ownership, Set-UID state, and the identity of the caller. This isolates the role of secure-execution mode in the dynamic loader.

The results show that `LD_PRELOAD` is honored when there is no privileged transition, but it is stripped when the executable runs with different real and effective user IDs. That is why the override disappears in the Set-UID cases executed by another user, but reappears when the Set-UID root binary is run directly by `root`.

### 4) Tools and Methods Used
Compilation and execution were handled by [run_task2_docker.sh](../../../tools/run_task2_docker.sh). Screenshot rendering used [render_terminal_capture.sh](../../../tools/render_terminal_capture.sh).
