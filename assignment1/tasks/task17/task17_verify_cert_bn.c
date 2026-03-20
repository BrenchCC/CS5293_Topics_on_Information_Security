#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/bn.h>
#include <openssl/sha.h>

static unsigned char SHA256_DIGESTINFO_PREFIX[] = {
    0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01,
    0x65, 0x03, 0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20
};

static int read_binary_file(const char *path, unsigned char **data, size_t *len)
{
    FILE *fp = NULL;
    long size = 0;
    unsigned char *buf = NULL;

    fp = fopen(path, "rb");
    if (fp == NULL) {
        return 0;
    }
    if (fseek(fp, 0, SEEK_END) != 0) {
        fclose(fp);
        return 0;
    }
    size = ftell(fp);
    if (size < 0) {
        fclose(fp);
        return 0;
    }
    if (fseek(fp, 0, SEEK_SET) != 0) {
        fclose(fp);
        return 0;
    }

    buf = (unsigned char *)malloc((size_t)size);
    if (buf == NULL) {
        fclose(fp);
        return 0;
    }

    if (fread(buf, 1, (size_t)size, fp) != (size_t)size) {
        free(buf);
        fclose(fp);
        return 0;
    }
    fclose(fp);

    *data = buf;
    *len = (size_t)size;
    return 1;
}

static int read_hex_file(const char *path, char **hex_out)
{
    unsigned char *raw = NULL;
    size_t raw_len = 0;
    size_t i = 0;
    size_t j = 0;
    char *hex = NULL;

    if (!read_binary_file(path, &raw, &raw_len)) {
        return 0;
    }

    hex = (char *)malloc(raw_len + 1);
    if (hex == NULL) {
        free(raw);
        return 0;
    }

    for (i = 0; i < raw_len; i++) {
        if (isxdigit(raw[i])) {
            hex[j++] = (char)toupper(raw[i]);
        }
    }
    hex[j] = '\0';

    free(raw);
    *hex_out = hex;
    return 1;
}

int main(int argc, char **argv)
{
    BN_CTX *ctx = NULL;
    BIGNUM *n = NULL;
    BIGNUM *e = NULL;
    BIGNUM *sig = NULL;
    BIGNUM *m = NULL;

    unsigned char *body = NULL;
    size_t body_len = 0;
    unsigned char hash[SHA256_DIGEST_LENGTH];

    char *n_hex = NULL;
    char *e_hex = NULL;
    char *sig_hex = NULL;

    unsigned char *em = NULL;
    int k = 0;
    int valid = 0;
    int i = 0;
    int sep = -1;

    if (argc != 5) {
        fprintf(stderr, "Usage: %s <issuer_n_hex_file> <issuer_e_hex_file> <signature_hex_file> <cert_body_bin>\n", argv[0]);
        return 1;
    }

    if (!read_hex_file(argv[1], &n_hex) || !read_hex_file(argv[2], &e_hex) || !read_hex_file(argv[3], &sig_hex)) {
        fprintf(stderr, "Failed to read hex input files.\n");
        return 1;
    }

    if (!read_binary_file(argv[4], &body, &body_len)) {
        fprintf(stderr, "Failed to read certificate body file.\n");
        return 1;
    }

    SHA256(body, body_len, hash);

    ctx = BN_CTX_new();
    n = BN_new();
    e = BN_new();
    sig = BN_new();
    m = BN_new();

    BN_hex2bn(&n, n_hex);
    BN_hex2bn(&e, e_hex);
    BN_hex2bn(&sig, sig_hex);

    BN_mod_exp(m, sig, e, n, ctx);

    k = BN_num_bytes(n);
    em = (unsigned char *)malloc((size_t)k);
    if (em == NULL) {
        fprintf(stderr, "Memory allocation failure.\n");
        return 1;
    }

    BN_bn2binpad(m, em, k);

    printf("SHA256(c0_body.bin) = ");
    for (i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        printf("%02X", hash[i]);
    }
    printf("\n");

    if (k >= 11 && em[0] == 0x00 && em[1] == 0x01) {
        for (i = 2; i < k; i++) {
            if (em[i] == 0x00) {
                sep = i;
                break;
            }
            if (em[i] != 0xFF) {
                sep = -1;
                break;
            }
        }

        if (sep > 2) {
            int payload_len = k - (sep + 1);
            int expected_len = (int)sizeof(SHA256_DIGESTINFO_PREFIX) + SHA256_DIGEST_LENGTH;

            if (payload_len == expected_len) {
                if (memcmp(em + sep + 1, SHA256_DIGESTINFO_PREFIX, sizeof(SHA256_DIGESTINFO_PREFIX)) == 0 &&
                    memcmp(em + sep + 1 + sizeof(SHA256_DIGESTINFO_PREFIX), hash, SHA256_DIGEST_LENGTH) == 0) {
                    valid = 1;
                }
            }
        }
    }

    printf("PKCS#1 v1.5 digest check = %s\n", valid ? "VALID" : "INVALID");

    free(n_hex);
    free(e_hex);
    free(sig_hex);
    free(body);
    free(em);

    BN_free(n);
    BN_free(e);
    BN_free(sig);
    BN_free(m);
    BN_CTX_free(ctx);

    return 0;
}
