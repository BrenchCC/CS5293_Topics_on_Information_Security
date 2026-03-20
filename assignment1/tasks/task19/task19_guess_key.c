#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/evp.h>

typedef unsigned long long u64;

static int hex_to_bytes(const char *hex, unsigned char *out, int out_len)
{
    int i = 0;
    for (i = 0; i < out_len; i++) {
        unsigned int x = 0;
        if (sscanf(hex + (i * 2), "%2x", &x) != 1) {
            return 0;
        }
        out[i] = (unsigned char)x;
    }
    return 1;
}

static int decrypt_one_block(
    const unsigned char key[16],
    const unsigned char iv[16],
    const unsigned char c[16],
    unsigned char p[16]
)
{
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    int out_len1 = 0;
    int out_len2 = 0;
    int ok = 0;

    if (ctx == NULL) {
        return 0;
    }

    if (EVP_DecryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, iv) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }
    EVP_CIPHER_CTX_set_padding(ctx, 0);

    if (EVP_DecryptUpdate(ctx, p, &out_len1, c, 16) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }

    if (EVP_DecryptFinal_ex(ctx, p + out_len1, &out_len2) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }

    ok = (out_len1 + out_len2 == 16);
    EVP_CIPHER_CTX_free(ctx);
    return ok;
}

int main(int argc, char **argv)
{
    const char *pt_hex = "255044462d312e350a25d0d4c5d80a34";
    const char *ct_hex = "d06bf9d0dab8e8ef880660d2af65aa82";
    const char *iv_hex = "09080706050403020100A2B2C2D2E2F2";

    unsigned char pt_known[16];
    unsigned char ct_known[16];
    unsigned char iv[16];
    unsigned char key[16];
    unsigned char out[16];

    u64 start = 0;
    u64 end = 0;
    u64 seed = 0;
    int i = 0;
    int found = 0;

    if (argc != 3) {
        fprintf(stderr, "Usage: %s <start_epoch> <end_epoch>\n", argv[0]);
        return 1;
    }

    start = strtoull(argv[1], NULL, 10);
    end = strtoull(argv[2], NULL, 10);

    if (!hex_to_bytes(pt_hex, pt_known, 16) || !hex_to_bytes(ct_hex, ct_known, 16) || !hex_to_bytes(iv_hex, iv, 16)) {
        fprintf(stderr, "Failed to parse fixed hex values.\n");
        return 1;
    }

    for (seed = start; seed <= end; seed++) {
        srand((unsigned int)seed);
        for (i = 0; i < 16; i++) {
            key[i] = (unsigned char)(rand() % 256);
        }

        if (!decrypt_one_block(key, iv, ct_known, out)) {
            continue;
        }

        if (memcmp(out, pt_known, 16) == 0) {
            printf("FOUND\n");
            printf("seed = %llu\n", seed);
            printf("key_hex = ");
            for (i = 0; i < 16; i++) {
                printf("%02x", key[i]);
            }
            printf("\n");
            printf("decrypted_first_block_hex = ");
            for (i = 0; i < 16; i++) {
                printf("%02x", out[i]);
            }
            printf("\n");
            found = 1;
            break;
        }

        if (seed == 18446744073709551615ULL) {
            break;
        }
    }

    if (!found) {
        printf("NOT_FOUND\n");
    }

    return 0;
}
