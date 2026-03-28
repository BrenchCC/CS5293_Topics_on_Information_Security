## Task 03 Report (Task 5.3 Modify the `secret[1]` Value)

### 1) What Was Done
I used `%n` to write through the `int_input` stack slot after consuming the first 20 stack arguments. The summary evidence is in [task03_summary.txt](./output/task03_summary.txt), with screenshot evidence in [task03_summary.png](./output/task03_summary.png).

### 2) Decimal Integer and Format String
The exact input is stored in [task03_input.txt](./task03_input.txt):

```text
1082146884
%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%n
```

### 3) How `%n` Writes to the Target Address
The first 20 `%c` conversions consume stack arguments 1 through 20. Each `%c` prints exactly one character, so the total printed character count is 20 when `printf` reaches `%n`.

At that point, `%n` uses stack argument 21, which is `int_input = 0x40804044`. Therefore `printf` writes the current character count, `20` decimal (`0x14`), into `secret[1]`.

### 4) Observed Result
The captured output in [task03_run.txt](./output/task03_run.txt) shows:

```text
The original secrets: 0x44 -- 0x55
The new secrets: 0x44 -- 0x14
```

So the exploit successfully modified `secret[1]`.

### 5) Tools and Methods Used
I reused the same stack-position discovery and targeted the printed runtime address of `secret[1]` through the decimal integer input.
