#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"

mkdir -p "${OUT_DIR}"

ENTROPY_FILE="/proc/sys/kernel/random/entropy_avail"
HAS_ENTROPY_COUNTER="yes"
if [ ! -r "${ENTROPY_FILE}" ]; then
    HAS_ENTROPY_COUNTER="no"
fi

RANDOM_OUT="${OUT_DIR}/task21_random_stream.bin"
: > "${RANDOM_OUT}"

START_TS=$(date +%s)
dd if=/dev/random of="${RANDOM_OUT}" bs=1 count=1048576 status=none &
DD_PID=$!

{
    echo "[Monitoring /dev/random read process for 8 seconds]"
    for i in $(seq 1 8); do
        sleep 1
        SIZE=$(wc -c < "${RANDOM_OUT}" | tr -d ' ')
        if [ "${HAS_ENTROPY_COUNTER}" = "yes" ]; then
            ENT=$(cat "${ENTROPY_FILE}")
        else
            ENT="N/A"
        fi
        ALIVE="yes"
        if ! kill -0 "${DD_PID}" 2>/dev/null; then
            ALIVE="no"
        fi
        echo "t=${i}s size_bytes=${SIZE} entropy=${ENT} dd_alive=${ALIVE}"
    done
} > "${OUT_DIR}/task21_monitor.txt"

BLOCKED="no"
if kill -0 "${DD_PID}" 2>/dev/null; then
    BLOCKED="yes"
    kill "${DD_PID}" 2>/dev/null || true
fi
wait "${DD_PID}" 2>/dev/null || true
END_TS=$(date +%s)

FINAL_SIZE=$(wc -c < "${RANDOM_OUT}" | tr -d ' ')

{
    echo "entropy_counter_available=${HAS_ENTROPY_COUNTER}"
    echo "Duration_seconds=$((END_TS - START_TS))"
    echo "Final_bytes_from_dev_random=${FINAL_SIZE}"
    echo "Blocked_or_slow=yes_if_process_still_running_after_8s=${BLOCKED}"
    echo
    echo "Monitor log: task21_monitor.txt"
    echo "DoS note: Repeatedly forcing a server to draw session keys from /dev/random can deplete entropy and make key generation block, delaying or denying client service."
} > "${OUT_DIR}/task21_result.txt"

cat "${OUT_DIR}/task21_result.txt"
