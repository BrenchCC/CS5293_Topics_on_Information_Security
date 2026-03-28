#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
host_uid="$(id -u)"
host_gid="$(id -g)"
runtime_image="debian:bookworm-slim"

compile_x86() {
    local source_file="$1"
    local output_file="$2"
    shift 2

    zig cc -target x86-linux-musl "$source_file" -o "$output_file" "$@"
}

compile_x64() {
    local source_file="$1"
    local output_file="$2"

    zig cc -target x86_64-linux-musl "$source_file" -o "$output_file"
}

mkdir -p "$repo_root/assignment2/tasks/task3/task01/output"
mkdir -p "$repo_root/assignment2/tasks/task3/task02/output"
mkdir -p "$repo_root/assignment2/tasks/task3/task03/output"
mkdir -p "$repo_root/assignment2/tasks/task3/task04/output"
mkdir -p "$repo_root/assignment2/tasks/task3/task05/output"
mkdir -p "$repo_root/assignment2/tasks/task3/task06/output"

compile_x86 "$repo_root/assignment2/tasks/task3/task01/call_shellcode.c" "$repo_root/assignment2/tasks/task3/task01/output/call_shellcode" -z execstack
compile_x86 "$repo_root/assignment2/tasks/task3/task02/stack_info.c" "$repo_root/assignment2/tasks/task3/task02/output/stack_info" -fno-stack-protector -fno-omit-frame-pointer -z execstack
compile_x86 "$repo_root/assignment2/tasks/task3/task02/stack.c" "$repo_root/assignment2/tasks/task3/task02/output/stack" -fno-stack-protector -fno-omit-frame-pointer -z execstack
compile_x64 "$repo_root/assignment2/tools/privsh64.c" "$repo_root/assignment2/tools/privsh64"

docker run --rm \
    --platform linux/amd64 \
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

mkdir -p /tmp/task3/task01 /tmp/task3/task02 /tmp/task3/task03 /tmp/task3/task04 /tmp/task3/task05 /tmp/task3/task06

run_as_seed() {
    su -s /usr/bin/bash seed -c "$1"
}

cp /workspace/assignment2/tools/privsh64 /usr/local/bin/privsh64
chmod 755 /usr/local/bin/privsh64

# Task 3.2
cp /workspace/assignment2/tasks/task3/task01/output/call_shellcode /tmp/task3/task01/call_shellcode
run_as_seed "bash -lc '\''cd /tmp/task3/task01; printf \"whoami\nexit\n\" | ./call_shellcode'\''" > /workspace/assignment2/tasks/task3/task01/output/task01_call_shellcode.txt 2>&1

# Helper for Task 3.4 baseline
cp /workspace/assignment2/tasks/task3/task02/output/stack_info /tmp/task3/task02/stack_info
setarch linux32 -R /tmp/task3/task02/stack_info > /workspace/assignment2/tasks/task3/task02/output/task02_stack_info.txt 2>&1
BUFFER_ADDR=$(grep "^buffer=" /workspace/assignment2/tasks/task3/task02/output/task02_stack_info.txt | sed "s/^buffer=//")
OFFSET=$(grep "^offset=" /workspace/assignment2/tasks/task3/task02/output/task02_stack_info.txt | sed "s/^offset=//")
BUFFER_HEX=${BUFFER_ADDR#0x}
RET_ADDR=$(printf "0x%x" $((16#$BUFFER_HEX + 200)))
echo "$RET_ADDR" > /workspace/assignment2/tasks/task3/task02/output/task02_ret_addr.txt
echo "$OFFSET" > /workspace/assignment2/tasks/task3/task02/output/task02_offset.txt
'
