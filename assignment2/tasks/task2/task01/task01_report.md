## Task 01 Report (Manipulating Environment Variables)

### 1) What Was Done
I used `printenv` to inspect the current environment in the `seed` account and demonstrated how `export` creates a variable and how `unset` removes it.

The recorded command transcript is in [task01_env_demo.txt](./output/task01_env_demo.txt), and the screenshot-friendly rendering is [task01_env_demo.png](./output/task01_env_demo.png).

### 2) Key Evidence and Results
The evidence shows two required observations:

- `printenv` successfully listed the current environment variables.
- After `export TASK2_DEMO="test string"`, `printenv TASK2_DEMO` printed `test string`.
- After `unset TASK2_DEMO`, `printenv TASK2_DEMO` produced no value.

This satisfies the required demonstration of printing, setting, and unsetting environment variables.

### 3) Tools and Methods Used
The commands were executed through the Linux runtime workflow in [run_task2_docker.sh](../../../tools/run_task2_docker.sh), and the output was rendered into a report-friendly screenshot using [render_terminal_capture.sh](../../../tools/render_terminal_capture.sh).
