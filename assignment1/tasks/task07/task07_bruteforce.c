#include <openssl/evp.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define KEY_LEN 16

static int hex_value(char c)
{
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    return -1;
}

static int hex_to_bytes(const char *hex, unsigned char *out, size_t out_len)
{
    size_t hex_len = strlen(hex);
    if (hex_len != out_len * 2) {
        return 0;
    }

    for (size_t i = 0; i < out_len; i++) {
        int hi = hex_value(hex[2 * i]);
        int lo = hex_value(hex[2 * i + 1]);
        if (hi < 0 || lo < 0) {
            return 0;
        }
        out[i] = (unsigned char)((hi << 4) | lo);
    }

    return 1;
}

static int aes_128_cbc_decrypt(
    const unsigned char *cipher,
    int cipher_len,
    const unsigned char *key,
    const unsigned char *iv,
    unsigned char *plain,
    int *plain_len
)
{
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    int len = 0;
    int total = 0;

    if (ctx == NULL) {
        return 0;
    }

    if (EVP_DecryptInit_ex(ctx, EVP_aes_128_cbc(), NULL, key, iv) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }

    if (EVP_DecryptUpdate(ctx, plain, &len, cipher, cipher_len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }
    total = len;

    if (EVP_DecryptFinal_ex(ctx, plain + total, &len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return 0;
    }
    total += len;

    *plain_len = total;
    EVP_CIPHER_CTX_free(ctx);
    return 1;
}

int main(int argc, char *argv[])
{
    const char *dict_path = "../../assignment1-supplymentary/words.txt";
    const char *target_plain = "This is a top secret.";
    const char *cipher_hex = "764aa26b55a4da654df6b19e4bce00f4ed05e09346fb0e762583cb7da2ac93a2";
    const char *iv_hex = "aabbccddeeff00998877665544332211";

    unsigned char cipher[32];
    unsigned char iv[16];
    FILE *fp = NULL;
    char line[512];
    int found = 0;

    if (argc >= 2) {
        dict_path = argv[1];
    }

    if (!hex_to_bytes(cipher_hex, cipher, sizeof(cipher))) {
        fprintf(stderr, "cipher hex parse failed\n");
        return 1;
    }
    if (!hex_to_bytes(iv_hex, iv, sizeof(iv))) {
        fprintf(stderr, "iv hex parse failed\n");
        return 1;
    }

    fp = fopen(dict_path, "r");
    if (fp == NULL) {
        perror("fopen dictionary");
        return 1;
    }

    while (fgets(line, sizeof(line), fp) != NULL) {
        size_t len = strcspn(line, "\r\n");
        unsigned char key[KEY_LEN];
        unsigned char plain[128];
        int plain_len = 0;

        line[len] = '\0';

        if (len == 0 || len >= KEY_LEN) {
            continue;
        }

        memset(key, '#', sizeof(key));
        memcpy(key, line, len);

        if (!aes_128_cbc_decrypt(cipher, (int)sizeof(cipher), key, iv, plain, &plain_len)) {
            continue;
        }

        if (plain_len == (int)strlen(target_plain) && memcmp(plain, target_plain, plain_len) == 0) {
            char key_hex[KEY_LEN * 2 + 1];
            for (int i = 0; i < KEY_LEN; i++) {
                snprintf(key_hex + 2 * i, 3, "%02x", key[i]);
            }
            plain[plain_len] = '\0';

            printf("Recovered dictionary word key: %s\n", line);
            printf("Padded 128-bit key (ASCII): ");
            for (int i = 0; i < KEY_LEN; i++) {
                putchar((char)key[i]);
            }
            printf("\n");
            printf("Padded 128-bit key (hex): %s\n", key_hex);
            printf("Decrypted plaintext: %s\n", plain);
            found = 1;
            break;
        }
    }

    fclose(fp);

    if (!found) {
        printf("No key found in dictionary: %s\n", dict_path);
        return 2;
    }

    return 0;
}
