#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
host_uid="$(id -u)"
host_gid="$(id -g)"
target="aarch64-linux-gnu"
runtime_image="python:3.11-slim"

compile_binary() {
    local source_file="$1"
    local output_file="$2"

    zig cc -target "$target" "$source_file" -o "$output_file"
}

compile_shared() {
    local source_file="$1"
    local output_file="$2"

    zig cc -target "$target" -fPIC -shared "$source_file" -o "$output_file"
}

mkdir -p "$repo_root/assignment2/tasks/task01/output"
mkdir -p "$repo_root/assignment2/tasks/task02/output"
mkdir -p "$repo_root/assignment2/tasks/task03/output"
mkdir -p "$repo_root/assignment2/tasks/task04/output"
mkdir -p "$repo_root/assignment2/tasks/task05/output"
mkdir -p "$repo_root/assignment2/tasks/task06/output"

compile_binary "$repo_root/assignment2/tasks/task02/setuidenv.c" "$repo_root/assignment2/tasks/task02/output/setuidenv"
compile_binary "$repo_root/assignment2/tasks/task03/myls.c" "$repo_root/assignment2/tasks/task03/output/myls"
compile_binary "$repo_root/assignment2/tasks/task03/ls.c" "$repo_root/assignment2/tasks/task03/output/ls"
compile_binary "$repo_root/assignment2/tasks/task04/myprog.c" "$repo_root/assignment2/tasks/task04/output/myprog"
compile_shared "$repo_root/assignment2/tasks/task04/mylib.c" "$repo_root/assignment2/tasks/task04/output/libmylib.so.1.0.1"
compile_binary "$repo_root/assignment2/tasks/task05/catwrapper.c" "$repo_root/assignment2/tasks/task05/output/catwrapper"
compile_binary "$repo_root/assignment2/tasks/task05/catwrapper_execve.c" "$repo_root/assignment2/tasks/task05/output/catwrapper_execve"
compile_binary "$repo_root/assignment2/tasks/task06/cap_leak.c" "$repo_root/assignment2/tasks/task06/output/cap_leak"
compile_binary "$repo_root/assignment2/tools/privsh.c" "$repo_root/assignment2/tools/privsh"

docker run --rm \
    -e HOST_UID="$host_uid" \
    -e HOST_GID="$host_gid" \
    -v "$repo_root:/workspace" \
    -w /workspace \
    "$runtime_image" \
    bash -lc '
set -euo pipefail

if ! id -u seed >/dev/null 2>&1; then
    useradd -m -s /usr/bin/bash seed
    echo "seed:seed" | chpasswd
fi

if ! id -u user1 >/dev/null 2>&1; then
    useradd -m -s /usr/bin/bash user1
    echo "user1:user1" | chpasswd
fi

run_as_seed() {
    su -s /usr/bin/bash seed -c "$1"
}

mkdir -p /tmp/task02 /tmp/task03 /tmp/task04 /tmp/task05 /tmp/task06

# Task 2.1
task01_log="/workspace/assignment2/tasks/task01/output/task01_env_demo.txt"
{
    echo "$ printenv | head -n 20"
    run_as_seed "bash -lc '\''printenv | head -n 20'\''"
    echo
    echo "$ export TASK2_DEMO=\"test string\""
    echo "$ printenv TASK2_DEMO"
    run_as_seed "bash -lc '\''export TASK2_DEMO=\"test string\"; printenv TASK2_DEMO'\''"
    echo
    echo "$ unset TASK2_DEMO"
    echo "$ printenv TASK2_DEMO"
    run_as_seed "bash -lc '\''export TASK2_DEMO=\"test string\"; unset TASK2_DEMO; printenv TASK2_DEMO || true'\''"
} > "$task01_log" 2>&1

# Task 2.2
cp /workspace/assignment2/tasks/task02/output/setuidenv /tmp/task02/setuidenv
chown root:root /tmp/task02/setuidenv
chmod 4755 /tmp/task02/setuidenv
task02_log="/workspace/assignment2/tasks/task02/output/task02_setuid_env.txt"
task02_filtered="/workspace/assignment2/tasks/task02/output/task02_filtered_vars.txt"
run_as_seed "bash -lc '\''export PATH=/tmp/task2_path:\$PATH; export LD_LIBRARY_PATH=/tmp/task2_ld_path; export ANY_NAME=seed_magic; /tmp/task02/setuidenv'\''" > "$task02_log" 2>&1
grep -E "^(PATH|LD_LIBRARY_PATH|ANY_NAME)=" "$task02_log" > "$task02_filtered" || true

# Task 2.3
cp /workspace/assignment2/tasks/task03/output/ls /home/seed/ls
chown seed:seed /home/seed/ls
chmod 755 /home/seed/ls
cp /workspace/assignment2/tasks/task03/output/myls /tmp/task03/myls
chown root:root /tmp/task03/myls
chmod 4755 /tmp/task03/myls
readlink /bin/sh > /workspace/assignment2/tasks/task03/output/bin_sh_before.txt
run_as_seed "bash -lc '\''export PATH=/home/seed:\$PATH; /tmp/task03/myls'\''" > /workspace/assignment2/tasks/task03/output/task03_dash.txt 2>&1
cp /workspace/assignment2/tools/privsh /usr/local/bin/privsh
chmod 755 /usr/local/bin/privsh
ln -sf /usr/local/bin/privsh /bin/sh
run_as_seed "bash -lc '\''export PATH=/home/seed:\$PATH; /tmp/task03/myls'\''" > /workspace/assignment2/tasks/task03/output/task03_privsh.txt 2>&1
ln -sf dash /bin/sh
readlink /bin/sh > /workspace/assignment2/tasks/task03/output/bin_sh_after.txt

# Task 2.4
task04_dir="/workspace/assignment2/tasks/task04/output"
cp "$task04_dir/myprog" /tmp/task04/myprog
cp "$task04_dir/libmylib.so.1.0.1" /tmp/task04/libmylib.so.1.0.1
run_as_seed "bash -lc '\''cd /tmp/task04; export LD_PRELOAD=./libmylib.so.1.0.1; ./myprog'\''" > "$task04_dir/task04_case1_regular.txt" 2>&1
chown root:root /tmp/task04/myprog
chmod 4755 /tmp/task04/myprog
run_as_seed "bash -lc '\''cd /tmp/task04; export LD_PRELOAD=./libmylib.so.1.0.1; ./myprog'\''" > "$task04_dir/task04_case2_setuid_root_normal_user.txt" 2>&1
bash -lc "cd /tmp/task04; export LD_PRELOAD=./libmylib.so.1.0.1; ./myprog" > "$task04_dir/task04_case3_setuid_root_root_user.txt" 2>&1
chown user1:user1 /tmp/task04/myprog
chmod 4755 /tmp/task04/myprog
run_as_seed "bash -lc '\''cd /tmp/task04; export LD_PRELOAD=./libmylib.so.1.0.1; ./myprog'\''" > "$task04_dir/task04_case4_setuid_user1_other_user.txt" 2>&1
{
    echo "Experiment design:"
    echo "1. Run the normal binary as seed with LD_PRELOAD pointing to libmylib.so.1.0.1."
    echo "2. Change ownership to root and enable the setuid bit, then run it again as seed."
    echo "3. Keep the binary as setuid-root and execute it directly as root."
    echo "4. Change ownership to user1, keep the setuid bit, and execute it as seed."
    echo
    echo "Observed cause:"
    echo "- LD_PRELOAD is honored when there is no privilege transition."
    echo "- The dynamic loader strips LD_PRELOAD in secure-execution mode when the real and effective UIDs differ."
    echo "- The root-run case preserves both UIDs as 0, so LD_PRELOAD is active again."
} > "$task04_dir/task04_experiment_notes.txt"

# Task 2.5
mkdir -p /tmp/task25
echo "TOP SECRET" > /tmp/task25/secret.txt
echo "DO NOT MODIFY" > /tmp/task25/protected.txt
chown root:root /tmp/task25/secret.txt /tmp/task25/protected.txt
chmod 644 /tmp/task25/secret.txt /tmp/task25/protected.txt
cp /workspace/assignment2/tasks/task05/output/catwrapper /tmp/task05/catwrapper
cp /workspace/assignment2/tasks/task05/output/catwrapper_execve /tmp/task05/catwrapper_execve
chown root:root /tmp/task05/catwrapper
chmod 4755 /tmp/task05/catwrapper
ln -sf /usr/local/bin/privsh /bin/sh
run_as_seed "bash -lc '\''/tmp/task05/catwrapper \"/tmp/task25/secret.txt; echo compromised > /tmp/task25/protected.txt\"'\''" > /workspace/assignment2/tasks/task05/output/task05_system_attack.txt 2>&1
chown root:root /tmp/task05/catwrapper_execve
chmod 4755 /tmp/task05/catwrapper_execve
run_as_seed "bash -lc '\''/tmp/task05/catwrapper_execve \"/tmp/task25/secret.txt; echo compromised > /tmp/task25/protected.txt\"'\''" > /workspace/assignment2/tasks/task05/output/task05_execve_attack.txt 2>&1 || true
ln -sf dash /bin/sh
{
    echo "protected.txt contents:"
    cat /tmp/task25/protected.txt
    echo
    echo "secret.txt contents:"
    cat /tmp/task25/secret.txt
} > /workspace/assignment2/tasks/task05/output/task05_file_state.txt

# Task 2.6
echo "Original line" > /etc/zzz
chmod 644 /etc/zzz
chown root:root /etc/zzz
cp /workspace/assignment2/tasks/task06/output/cap_leak /tmp/task06/cap_leak
chown root:root /tmp/task06/cap_leak
chmod 4755 /tmp/task06/cap_leak
cat /etc/zzz > /workspace/assignment2/tasks/task06/output/task06_before.txt
run_as_seed "bash -lc '\''/tmp/task06/cap_leak'\''" > /workspace/assignment2/tasks/task06/output/task06_run.txt 2>&1
cat /etc/zzz > /workspace/assignment2/tasks/task06/output/task06_after.txt

chown -R "${HOST_UID}:${HOST_GID}" /workspace/assignment2/tasks /workspace/assignment2/tools || true
'
