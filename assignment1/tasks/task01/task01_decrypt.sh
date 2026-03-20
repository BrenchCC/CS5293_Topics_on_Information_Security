#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSIGN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CIPHER_FILE="$ASSIGN_DIR/assignment1-supplymentary/ciphertext.txt"
OUT_DIR="$SCRIPT_DIR/output"

mkdir -p "$OUT_DIR"

if [[ ! -f "$CIPHER_FILE" ]]; then
  echo "Ciphertext file not found: $CIPHER_FILE" >&2
  exit 1
fi

# Ciphertext alphabet: abcdefghijklmnopqrstuvwxyz
# Plaintext mapping:   cfmypvbrlqxwiejdsgkhnazotu
MAPPING="cfmypvbrlqxwiejdsgkhnazotu"

# Decrypt full text.
tr 'abcdefghijklmnopqrstuvwxyz' "$MAPPING" < "$CIPHER_FILE" > "$OUT_DIR/plaintext.txt"

# Unigram frequency.
tr -cd 'a-z' < "$CIPHER_FILE" \
  | fold -w1 \
  | sort \
  | uniq -c \
  | sort -nr \
  > "$OUT_DIR/unigram_top.txt"

# Bigram frequency (within each line).
tr -cd 'a-z\n' < "$CIPHER_FILE" \
  | sed 's/[^a-z]//g' \
  | awk '{for(i = 1; i < length($0); i++) print substr($0, i, 2)}' \
  | sort \
  | uniq -c \
  | sort -nr \
  > "$OUT_DIR/bigram_top.txt"

# Trigram frequency (within each line).
tr -cd 'a-z\n' < "$CIPHER_FILE" \
  | sed 's/[^a-z]//g' \
  | awk '{for(i = 1; i < length($0) - 1; i++) print substr($0, i, 3)}' \
  | sort \
  | uniq -c \
  | sort -nr \
  > "$OUT_DIR/trigram_top.txt"

cat > "$OUT_DIR/mapping_cipher_to_plain.txt" <<'MAP'
a -> c
b -> f
c -> m
d -> y
e -> p
f -> v
g -> b
h -> r
i -> l
j -> q
k -> x
l -> w
m -> i
n -> e
o -> j
p -> d
q -> s
r -> g
s -> k
t -> h
u -> n
v -> a
w -> z
x -> o
y -> t
z -> u
MAP

# Extract an excerpt for reporting.
head -n 12 "$OUT_DIR/plaintext.txt" > "$OUT_DIR/plaintext_excerpt.txt"

echo "Generated files in $OUT_DIR"
ls -1 "$OUT_DIR"
