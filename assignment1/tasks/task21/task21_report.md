## Task 21 Report (Get Pseudo Random Numbers from /dev/random)

### 1) Observations of /dev/random Behavior
Main evidence: [task21_result.txt](./output/task21_result.txt)
Detailed monitor log: [task21_monitor.txt](./output/task21_monitor.txt)

I launched a continuous read process from `/dev/random` and monitored output growth over 8 seconds.

In this environment, the process completed without prolonged blocking during the test window.

### 2) Why This Behavior Happens
`/dev/random` behavior depends on OS implementation and entropy accounting policy. Traditional Linux behavior can block when entropy is depleted; this host does not expose Linux entropy counters and did not show blocking in this run.

### 3) DoS Answer
If a server relies on blocking random generation for session keys, an attacker can trigger many concurrent key-generation requests, forcing entropy consumption and causing key-generation delays/blocking, which can degrade availability (DoS effect).

### 4) Tools and Methods Used
- Script: [task21_dev_random.sh](./task21_dev_random.sh)
- `dd`, process monitoring (`kill -0`), file-size sampling
