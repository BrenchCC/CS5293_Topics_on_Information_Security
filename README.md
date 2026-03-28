# CS5293 Topics on Information Security

This repository contains course work, reproducible task artifacts, and report deliverables for **CS5293: Topics on Information Security**.

The project is organized by assignment. Each assignment folder keeps its own source materials, task implementations, generated outputs, and final write-up so the work can be reviewed or rerun without mixing files across assignments.

## Repository Layout

```text
.
├── assignment1/
│   ├── README.md
│   ├── answer.md
│   ├── sources/
│   ├── tasks/
│   └── tools/
├── assignment2/
│   ├── answer.md
│   ├── sources/
│   ├── tasks/
│   └── tools/
└── README.md
```

## Assignment Structure

### Assignment 1

`assignment1/` uses a flat per-task layout:

- `tasks/taskXX/`: code, notes, outputs, and task-level reports
- `answer.md`: cumulative assignment report
- `sources/`: extracted or supporting source material from the assignment handout
- `tools/`: helper binaries or utilities used by some tasks

See [assignment1/README.md](./assignment1/README.md) for assignment-specific usage notes.

### Assignment 2

`assignment2/` uses a nested layout grouped by major sections of the assignment:

- `tasks/task2/taskXX/`: Task 2 subtasks on environment variables and Set-UID behavior
- `tasks/task3/taskXX/`: Task 3 subtasks on buffer overflow
- `tasks/task4/taskXX/`: Task 4 subtasks on return-to-libc
- `tasks/task5/taskXX/`: Task 5 subtasks on format string vulnerability
- `answer.md`: cumulative assignment report with embedded evidence
- `sources/`: extracted handout content and helper scripts
- `tools/`: supporting programs and helper scripts

Useful entry points:

- [assignment2/answer.md](./assignment2/answer.md)
- [assignment2/tools/run_task2_docker.sh](./assignment2/tools/run_task2_docker.sh)
- [assignment2/tools/run_task3_docker.sh](./assignment2/tools/run_task3_docker.sh)

## Environment

This repository is primarily intended for a Unix-like environment. Several tasks assume tools commonly available on Linux security labs or SEED Ubuntu environments, such as:

- `gcc`
- `bash`
- `openssl`
- `perl`
- standard Unix utilities

Some tasks may also rely on 32-bit compilation support, Set-UID behavior, or containerized lab environments depending on the assignment.

Assignment 2 helper workflows additionally reference `docker`, `zig cc`, and terminal-capture tooling for reproducible screenshots.

## How to Navigate the Work

1. Start from the assignment folder you care about.
2. Read the assignment-level `README.md` if one exists.
3. Open `answer.md` for the consolidated write-up.
4. Inspect the corresponding `tasks/` subdirectories for scripts, evidence, screenshots, and intermediate outputs.

## Common Usage

Most task scripts are intended to be run from within the relevant assignment directory.

Example:

```bash
cd assignment1
bash ./tasks/task01/task01_decrypt.sh
```

For source-based tasks, compile the required program inside the assignment directory and then run the task script or generated binary as needed.

Example:

```bash
cd assignment1
gcc ./tasks/task16/task16_verify_bn.c -o ./tasks/task16/output/task16_verify_bn -lcrypto
bash ./tasks/task16/task16_verify.sh
```

Assignment 2 also includes helper automation scripts, for example:

```bash
bash ./assignment2/tools/run_task2_docker.sh
bash ./assignment2/tools/run_task3_docker.sh
```

## Reports and Deliverables

- Assignment-level reports are stored as `assignmentN/answer.md`
- Final exported reports or PDFs may also appear directly inside each assignment folder
- Task evidence is typically stored under each task's `output/` directory

## Notes

- Many outputs in this repository are generated as part of lab execution and are kept alongside the task that produced them.
- If you want to reproduce a result, check the corresponding task folder first because command sequences, screenshots, and helper code are usually stored there.
