# Assignment 1

This folder contains materials, scripts, outputs, and reports for CS5293 Assignment 1.

## Structure

- `tasks/taskXX/`: per-task implementation, evidence files, and `taskXX_report.md`
- `answer.md`: cumulative report that syncs all task reports
- `assignment1-supplymentary/`: provided source files from the assignment package
- `tools/`: helper binaries/tools used in some tasks

## Quick Start

Run task scripts from the project root:

```bash
cd assignment1
bash ./tasks/task01/task01_decrypt.sh
```

Compile and run C-based tasks (example):

```bash
cd assignment1
gcc ./tasks/task16/task16_verify_bn.c -o ./tasks/task16/output/task16_verify_bn -lcrypto
bash ./tasks/task16/task16_verify.sh
```

## Reports

- Per-task reports: `tasks/taskXX/taskXX_report.md`
- Aggregated report: [answer.md](./answer.md)

## Notes

- Most scripts assume OpenSSL and common Unix tools are available.
- Generated evidence is usually saved under each task's `output/` directory.
