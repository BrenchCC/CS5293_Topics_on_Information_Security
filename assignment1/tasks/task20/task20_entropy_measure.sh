#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/output"

mkdir -p "${OUT_DIR}"

ENTROPY_FILE="/proc/sys/kernel/random/entropy_avail"

if [ ! -r "${ENTROPY_FILE}" ]; then
    START_RANDOM=$(date +%s)
    head -c 65536 /dev/random > "${OUT_DIR}/task20_random_64k.bin"
    END_RANDOM=$(date +%s)

    START_URANDOM=$(date +%s)
    head -c 65536 /dev/urandom > "${OUT_DIR}/task20_urandom_64k.bin"
    END_URANDOM=$(date +%s)

    {
        echo "${ENTROPY_FILE} is unavailable on this system (non-Linux)."
        echo "Fallback observation: measured read time instead of entropy counter."
        echo "Read 64KB from /dev/random duration_seconds=$((END_RANDOM - START_RANDOM))"
        echo "Read 64KB from /dev/urandom duration_seconds=$((END_URANDOM - START_URANDOM))"
    } > "${OUT_DIR}/task20_result.txt"
    cat "${OUT_DIR}/task20_result.txt"
    exit 0
fi

sample_entropy() {
    local label="$1"
    local count="$2"
    local interval="$3"
    local out_file="$4"
    local i

    echo "[${label}]" > "${out_file}"
    for i in $(seq 1 "${count}"); do
        printf '%s sample_%02d entropy=%s\n' "$(date '+%H:%M:%S')" "${i}" "$(cat "${ENTROPY_FILE}")" >> "${out_file}"
        sleep "${interval}"
    done
}

sample_entropy "Idle sampling" 20 0.1 "${OUT_DIR}/task20_idle_samples.txt"

BEFORE_DISK=$(cat "${ENTROPY_FILE}")
for _ in $(seq 1 50); do
    dd if=/bin/bash of=/dev/null bs=64k count=1 status=none || true
done
AFTER_DISK=$(cat "${ENTROPY_FILE}")

BEFORE_URANDOM=$(cat "${ENTROPY_FILE}")
head -c 1048576 /dev/urandom > "${OUT_DIR}/task20_urandom_1m.bin"
AFTER_URANDOM=$(cat "${ENTROPY_FILE}")

sample_entropy "Post-activity sampling" 20 0.1 "${OUT_DIR}/task20_post_samples.txt"

{
    echo "Entropy file: ${ENTROPY_FILE}"
    echo "Disk read activity: before=${BEFORE_DISK}, after=${AFTER_DISK}"
    echo "Read 1MB from /dev/urandom: before=${BEFORE_URANDOM}, after=${AFTER_URANDOM}"
    echo
    echo "Idle samples file: task20_idle_samples.txt"
    echo "Post-activity samples file: task20_post_samples.txt"
} > "${OUT_DIR}/task20_result.txt"

cat "${OUT_DIR}/task20_result.txt"
