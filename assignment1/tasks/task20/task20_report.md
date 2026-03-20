## Task 20 Report (Measure the Entropy of Kernel)

### 1) Evidence Collected
Evidence file: [task20_result.txt](./output/task20_result.txt)

In this environment (macOS), Linux entropy interface `/proc/sys/kernel/random/entropy_avail` is not available, so direct entropy-counter monitoring with `watch` is not possible.

### 2) Activities and Observations
As a fallback, I measured read behavior on `/dev/random` and `/dev/urandom` for 64KB each.

Artifacts:
- [task20_random_64k.bin](./output/task20_random_64k.bin)
- [task20_urandom_64k.bin](./output/task20_urandom_64k.bin)

Observed durations are reported in [task20_result.txt](./output/task20_result.txt).

### 3) Brief Conclusion
The Linux-specific entropy counter could not be directly measured on this host, but random-device read behavior was still captured and recorded as supporting evidence.

### 4) Tools and Methods Used
- Shell script: [task20_entropy_measure.sh](./task20_entropy_measure.sh)
- `head`, `date`
