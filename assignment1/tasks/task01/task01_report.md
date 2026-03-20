## Task 01 Report (Monoalphabetic Substitution Cipher)

### 1) Recovered Substitution Mapping (Ciphertext -> Plaintext)

All 26 letters were recovered; no unknown mappings remain.

| Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain | Cipher | Plain |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| a | c | b | f | c | m | d | y | e | p | f | v | g | b |
| h | r | i | l | j | q | k | x | l | w | m | i | n | e |
| o | j | p | d | q | s | r | g | s | k | t | h | u | n |
| v | a | w | z | x | o | y | t | z | u |  |  |  |  |

### 2) A Short Excerpt of the Recovered Plaintext

See [plaintext_excerpt.txt](./output/plaintext_excerpt.txt):

> the oscars turn on sunday which seems about right after this long strange awards trip the bagger feels like a nonagenarian too
>
> the awards race was bookended by the demise of harvey weinstein at its outset and the apparent implosion of

### 3) Frequency-Analysis Evidence

Key evidence:
- High-frequency trigram `ytn` -> `the` (see [trigram_top.txt](./output/trigram_top.txt)).
- Frequent short word `vup` -> `and`.
- Word pattern `xqavhq` -> `oscars`, confirming `x -> o, q -> s, a -> c, v -> a, h -> r`.
- Proper noun pattern `lnmuqynmu` -> `weinstein`, validating several mappings together.
- N-gram frequencies become consistent with English after substitution (see [unigram_top.txt](./output/unigram_top.txt), [bigram_top.txt](./output/bigram_top.txt), and [trigram_top.txt](./output/trigram_top.txt)).

### 4) Tools and Methods Used
- Bash script: [task01_decrypt.sh](./task01_decrypt.sh)
- Outputs: [plaintext.txt](./output/plaintext.txt) and [mapping_cipher_to_plain.txt](./output/mapping_cipher_to_plain.txt)
- Command-line tools: `tr`, `awk`, `sort`, `uniq`, `head`
