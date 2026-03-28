## Task 04 Report (Task 5.4 Modify the `secret[1]` Value to 80 Decimal)

### 1) What Was Done
I refined the Task 5.3 `%n` attack so that the printed-character count was exactly 80 before the write. The summary evidence is in [task04_summary.txt](./output/task04_summary.txt), with screenshot evidence in [task04_summary.png](./output/task04_summary.png).

### 2) Decimal Integer and Format String
The exact input is stored in [task04_input.txt](./task04_input.txt):

```text
1082146884
%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%61c%n
```

### 3) How the Exact Value Was Controlled
The first 19 `%c` conversions print 19 characters while consuming stack arguments 1 through 19. The `%61c` conversion then consumes stack argument 20 and prints a field of width 61, so the cumulative character count becomes:

```text
19 + 61 = 80
```

The final `%n` uses stack argument 21, which is `int_input = 0x40804044`. Therefore `printf` writes exactly `80` decimal, i.e. `0x50`, into `secret[1]`.

### 4) Observed Result
The captured output in [task04_run.txt](./output/task04_run.txt) shows:

```text
The original secrets: 0x44 -- 0x55
The new secrets: 0x44 -- 0x50
```

This confirms that `secret[1]` was changed to the required predetermined value.

### 5) Tools and Methods Used
I reused the Task 5.3 `%n` technique and adjusted the printed-character count with a width-controlled `%61c` conversion.
