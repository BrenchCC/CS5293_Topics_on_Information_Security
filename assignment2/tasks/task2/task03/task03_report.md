## Task 03 Report (The PATH Environment Variable and Set-UID Programs)

### 1) Custom `ls.c` Code
The malicious replacement program is [ls.c](./ls.c):

```c
#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("This is my ls program\n");
    printf("My real uid is: %d\n", getuid());
    printf("My effective uid is: %d\n", geteuid());
    return 0;
}
```

The vulnerable Set-UID caller is [myls.c](./myls.c).

### 2) What Was Done
I compiled the Set-UID program that calls `system("ls")`, prepared a malicious `ls` in the `seed` account, and modified `PATH` so the malicious program appeared before the real `/bin/ls`.

I recorded two runs:

- Default `/bin/sh -> dash`: [task03_dash.txt](./output/task03_dash.txt)
- Countermeasure-disabled shell path: [task03_privsh.txt](./output/task03_privsh.txt)

The combined screenshot evidence is [task03_summary.png](./output/task03_summary.png).

### 3) Observations
The Set-UID program ran my custom code instead of the real `/bin/ls`.

Observed effective UIDs:

- With the default `dash` behavior, `geteuid()` became `1000`, so the shell dropped the privilege.
- With the countermeasure-disabled shell path, `geteuid()` remained `0`, so the malicious `ls` executed with root privilege.

### 4) Explanation
This attack works because `system()` invokes `/bin/sh -c "ls"`, and the shell resolves `ls` through `PATH`. By prepending the attacker-controlled directory to `PATH`, the Set-UID program can be tricked into running attacker code. Whether that code keeps root privilege depends on the shell’s privilege-dropping countermeasure.

### 5) Tools and Methods Used
Execution was automated by [run_task2_docker.sh](../../../tools/run_task2_docker.sh). Output rendering used [render_terminal_capture.sh](../../../tools/render_terminal_capture.sh).
