#include <openssl/bn.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void print_bn_hex(const char *label, const BIGNUM *bn)
{
    char *hex = BN_bn2hex(bn);
    if (hex == NULL) {
        fprintf(stderr, "BN_bn2hex failed\n");
        exit(1);
    }
    printf("%s%s\n", label, hex);
    OPENSSL_free(hex);
}

static void bytes_to_hex(const unsigned char *bytes, size_t len, char *hex_out)
{
    for (size_t i = 0; i < len; i++) {
        snprintf(hex_out + 2 * i, 3, "%02x", bytes[i]);
    }
    hex_out[2 * len] = '\0';
}

static void print_bn_as_ascii(const char *label, const BIGNUM *bn)
{
    int nbytes = BN_num_bytes(bn);
    unsigned char *buf = (unsigned char *)malloc((size_t)nbytes + 1);
    if (buf == NULL) {
        fprintf(stderr, "malloc failed\n");
        exit(1);
    }

    BN_bn2bin(bn, buf);
    buf[nbytes] = '\0';

    printf("%s", label);
    for (int i = 0; i < nbytes; i++) {
        unsigned char c = buf[i];
        if (c >= 32 && c <= 126) {
            putchar((char)c);
        } else {
            printf("\\x%02x", c);
        }
    }
    printf("\n");

    free(buf);
}

int main(void)
{
    BN_CTX *ctx = BN_CTX_new();
    if (ctx == NULL) {
        fprintf(stderr, "BN_CTX_new failed\n");
        return 1;
    }

    BIGNUM *p = BN_new();
    BIGNUM *q = BN_new();
    BIGNUM *e = BN_new();
    BIGNUM *n = BN_new();
    BIGNUM *phi = BN_new();
    BIGNUM *d = BN_new();
    BIGNUM *one = BN_new();
    BIGNUM *p_minus_1 = BN_new();
    BIGNUM *q_minus_1 = BN_new();
    BIGNUM *check = BN_new();

    BIGNUM *n_t13 = BN_new();
    BIGNUM *e_t13 = BN_new();
    BIGNUM *d_t13 = BN_new();
    BIGNUM *m_t13 = BN_new();
    BIGNUM *c_t13 = BN_new();
    BIGNUM *dec_t13 = BN_new();

    BIGNUM *c_t14 = BN_new();
    BIGNUM *m_t14 = BN_new();

    BIGNUM *m15_1 = BN_new();
    BIGNUM *m15_2 = BN_new();
    BIGNUM *s15_1 = BN_new();
    BIGNUM *s15_2 = BN_new();

    if (
        p == NULL || q == NULL || e == NULL || n == NULL || phi == NULL || d == NULL || one == NULL ||
        p_minus_1 == NULL || q_minus_1 == NULL || check == NULL || n_t13 == NULL || e_t13 == NULL ||
        d_t13 == NULL || m_t13 == NULL || c_t13 == NULL || dec_t13 == NULL || c_t14 == NULL ||
        m_t14 == NULL || m15_1 == NULL || m15_2 == NULL || s15_1 == NULL || s15_2 == NULL
    ) {
        fprintf(stderr, "BN_new failed\n");
        return 1;
    }

    BN_one(one);

    // Task 12 values
    BN_hex2bn(&p, "F7E75FDC469067FFDC4E847C51F452DF");
    BN_hex2bn(&q, "E85CED54AF57E53E092113E62F436F4F");
    BN_hex2bn(&e, "0D88C3");

    BN_mul(n, p, q, ctx);
    BN_sub(p_minus_1, p, one);
    BN_sub(q_minus_1, q, one);
    BN_mul(phi, p_minus_1, q_minus_1, ctx);

    if (BN_mod_inverse(d, e, phi, ctx) == NULL) {
        fprintf(stderr, "BN_mod_inverse failed\n");
        return 1;
    }

    BN_mod_mul(check, e, d, phi, ctx);

    printf("[Task12]\n");
    print_bn_hex("n = ", n);
    print_bn_hex("phi(n) = ", phi);
    print_bn_hex("d = ", d);
    print_bn_hex("(e*d) mod phi(n) = ", check);
    printf("\n");

    // Task 13 values
    BN_hex2bn(&n_t13, "DCBFFE3E51F62E09CE7032E2677A78946A849DC4CDDE3A4D0CB81629242FB1A5");
    BN_hex2bn(&e_t13, "010001");
    BN_hex2bn(&d_t13, "74D806F9F3A62BAE331FFE3F0A68AFE35B3D2E4794148AACBC26AA381CD7D30D");

    const char *msg13 = "A top secret!";
    size_t msg13_len = strlen(msg13);
    char msg13_hex[2 * 64 + 1];

    bytes_to_hex((const unsigned char *)msg13, msg13_len, msg13_hex);
    BN_hex2bn(&m_t13, msg13_hex);

    BN_mod_exp(c_t13, m_t13, e_t13, n_t13, ctx);
    BN_mod_exp(dec_t13, c_t13, d_t13, n_t13, ctx);

    printf("[Task13]\n");
    printf("M ASCII = %s\n", msg13);
    printf("M hex = %s\n", msg13_hex);
    print_bn_hex("C hex = ", c_t13);
    print_bn_hex("Decrypt(C) with d = ", dec_t13);
    print_bn_as_ascii("Decrypted ASCII = ", dec_t13);
    printf("\n");

    // Task 14
    BN_hex2bn(&c_t14, "8C0F971DF2F3672B28811407E2DABBE1DA0FEBBBDFC7DCB67396567EA1E2493F");
    BN_mod_exp(m_t14, c_t14, d_t13, n_t13, ctx);

    printf("[Task14]\n");
    print_bn_hex("C hex = ", c_t14);
    print_bn_hex("M hex = ", m_t14);
    print_bn_as_ascii("M ASCII = ", m_t14);
    printf("\n");

    // Task 15
    const char *msg15_1 = "I owe you $2000.";
    const char *msg15_2 = "I owe you $3000.";
    size_t msg15_1_len = strlen(msg15_1);
    size_t msg15_2_len = strlen(msg15_2);
    char msg15_1_hex[2 * 64 + 1];
    char msg15_2_hex[2 * 64 + 1];

    bytes_to_hex((const unsigned char *)msg15_1, msg15_1_len, msg15_1_hex);
    bytes_to_hex((const unsigned char *)msg15_2, msg15_2_len, msg15_2_hex);

    BN_hex2bn(&m15_1, msg15_1_hex);
    BN_hex2bn(&m15_2, msg15_2_hex);

    BN_mod_exp(s15_1, m15_1, d_t13, n_t13, ctx);
    BN_mod_exp(s15_2, m15_2, d_t13, n_t13, ctx);

    printf("[Task15]\n");
    printf("M1 ASCII = %s\n", msg15_1);
    printf("M1 hex = %s\n", msg15_1_hex);
    print_bn_hex("S1 hex = ", s15_1);
    printf("M2 ASCII = %s\n", msg15_2);
    printf("M2 hex = %s\n", msg15_2_hex);
    print_bn_hex("S2 hex = ", s15_2);

    BN_free(p);
    BN_free(q);
    BN_free(e);
    BN_free(n);
    BN_free(phi);
    BN_free(d);
    BN_free(one);
    BN_free(p_minus_1);
    BN_free(q_minus_1);
    BN_free(check);

    BN_free(n_t13);
    BN_free(e_t13);
    BN_free(d_t13);
    BN_free(m_t13);
    BN_free(c_t13);
    BN_free(dec_t13);

    BN_free(c_t14);
    BN_free(m_t14);

    BN_free(m15_1);
    BN_free(m15_2);
    BN_free(s15_1);
    BN_free(s15_2);

    BN_CTX_free(ctx);
    return 0;
}
