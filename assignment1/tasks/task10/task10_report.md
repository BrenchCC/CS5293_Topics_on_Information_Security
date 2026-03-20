## Task 10 Report (Generating Two Executable Files with the Same MD5 Hash)

### 1) What Was Done
I created a C program with a 200-byte global array `xyz` initialized to `0x41`, compiled it, located the array in the executable, split the binary into `prefix / 128-byte region / suffix`, generated a collision on the prefix, and rebuilt two executables.

Files:
- Source code: [task10_collision_exec.c](./task10_collision_exec.c)
- Automation script: [task10_collision_exec.sh](./task10_collision_exec.sh)


### 2) How the Executable Was Located and Split
Offset evidence: [task10_offsets.txt](./output/task10_offsets.txt)

Key values from this run:
- `array_offset = 32768`
- `region_start = 32768`
- `region_end = 32895`
- `region_len = 128`
- `prefix_len = 32768`
- `prefix_len mod 64 = 0` (satisfies collision-tool requirement)

Split artifacts:
- Prefix: [prefix.bin](./output/prefix.bin)
- Collision outputs: [collision1.bin](./output/collision1.bin), [collision2.bin](./output/collision2.bin)
- Suffix: [suffix.bin](./output/suffix.bin)

Final executables:
- [task10_prog1](./output/task10_prog1)
- [task10_prog2](./output/task10_prog2)

### 3) Evidence: Same MD5, Different `xyz` Contents
MD5 evidence: [task10_md5sum.txt](./output/task10_md5sum.txt)
MD5 screenshot: [task10_md5sum.txt.png](./output/task10_md5sum.txt.png)
- Both executables have MD5: `5b466ac9bda2c431c03bdf787c85b3b2`

Different printed `xyz` outputs:
- Program 1 output: [task10_prog1_output.txt](./output/task10_prog1_output.txt)
- Program 2 output: [task10_prog2_output.txt](./output/task10_prog2_output.txt)
- Program 1 screenshot: [task10_prog1_output.txt.png](./output/task10_prog1_output.txt.png)
- Program 2 screenshot: [task10_prog2_output.txt.png](./output/task10_prog2_output.txt.png)

Direct byte-level difference evidence in extracted `xyz` segment:
- [task10_prog1_xyz.hex](./output/task10_prog1_xyz.hex)
- [task10_prog2_xyz.hex](./output/task10_prog2_xyz.hex)
- [task10_xyz_diff_positions.txt](./output/task10_xyz_diff_positions.txt)

### 4) Tools and Methods Used
- Build: `clang`
- Binary processing: `xxd`, `head`, `tail`, `dd`, `cat`, `cmp`
- Collision generation: `md5collgen`
- Hash verification: `md5sum`
