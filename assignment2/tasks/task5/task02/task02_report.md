## Task 02 Report (Task 5.2 Print out the `secret[1]` Value)

### 1) What Was Done
I reused the same vulnerable program and the stack-position result from Task 5.1. The summary evidence is in [task02_summary.txt](./output/task02_summary.txt), with screenshot evidence in [task02_summary.png](./output/task02_summary.png).

### 2) Decimal Integer and Format String
The exact input is stored in [task02_input.txt](./task02_input.txt):

```text
1082146884
%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%s
```

`1082146884` is the decimal form of `0x40804044`, which is the printed runtime address of `secret[1]`.

### 3) How the Format String Reads the Target Value
The first 20 `%x` conversions consume the first 20 stack arguments. The final `%s` then uses the 21st argument, which is `int_input`. Because `int_input` contains the address of `secret[1]`, `printf` dereferences that heap address and prints the bytes stored there as a string.

At that moment `secret[1] = 0x00000055`, so the first byte is ASCII `U` and the following byte is `0x00`, which terminates the string immediately. The printed `U` therefore confirms the value `0x55`.

### 4) Observed Result
The run output in [task02_run.txt](./output/task02_run.txt) ends with:

```text
... .U
The original secrets: 0x44 -- 0x55
The new secrets: 0x44 -- 0x55
```

### 5) Tools and Methods Used
I used the same reconstructed Linux i386 binary, the stable runtime address of `secret[1]`, and the format-string stack-position result from Task 5.1.
