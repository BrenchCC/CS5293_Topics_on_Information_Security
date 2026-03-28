## Task 06 Report (Capability Leaking)

### 1) What Was Done
I compiled the capability-leaking demo from [cap_leak.c](./cap_leak.c), created `/etc/zzz` as a root-owned file, ran the Set-UID program as the normal `seed` user, and compared the file contents before and after execution.

Evidence files:

- Before: [task06_before.txt](./output/task06_before.txt)
- After: [task06_after.txt](./output/task06_after.txt)
- Screenshot summary: [task06_summary.png](./output/task06_summary.png)

### 2) Was `/etc/zzz` Modified?
Yes. The file changed from:

```text
Original line
```

to:

```text
Original line
Malicious Data
```

### 3) Explanation
Although the program called `setuid(getuid())` to drop root privilege, it kept an already-open privileged file descriptor to `/etc/zzz`. The child process inherited that descriptor after `fork()` and wrote to the file successfully. The privilege was therefore not fully removed; the process leaked a privileged capability through the open file descriptor.

### 4) Brief Explanation of Capability Leaking
Capability leaking happens when a privileged program relinquishes its effective UID but forgets to clean up powerful resources acquired earlier, such as open file descriptors. Those resources continue to grant privileged effects even after the UID has been lowered.

### 5) Tools and Methods Used
The execution workflow is in [run_task2_docker.sh](../../../tools/run_task2_docker.sh), and screenshot rendering used [render_terminal_capture.sh](../../../tools/render_terminal_capture.sh).
