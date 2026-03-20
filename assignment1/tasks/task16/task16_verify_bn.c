#include <stdio.h>
#include <string.h>
#include <openssl/bn.h>

static void ascii_to_hex(const char *ascii, char *hex_out, size_t hex_out_len)
{
    size_t i = 0;
    size_t n = strlen(ascii);

    if (hex_out_len < (n * 2 + 1)) {
        hex_out[0] = '\0';
        return;
    }

    for (i = 0; i < n; i++) {
        sprintf(hex_out + i * 2, "%02X", (unsigned char)ascii[i]);
    }
    hex_out[n * 2] = '\0';
}

int main(void)
{
    BN_CTX *ctx = BN_CTX_new();
    BIGNUM *n = BN_new();
    BIGNUM *e = BN_new();
    BIGNUM *s_ok = BN_new();
    BIGNUM *s_bad = BN_new();
    BIGNUM *m_expected = BN_new();
    BIGNUM *m_from_sig_ok = BN_new();
    BIGNUM *m_from_sig_bad = BN_new();

    const char *msg_ascii = "Launch a missle.";
    const char *sig_ok_hex = "643D6F34902D9C7EC90CB0B2BCA36C47FA37165C0005CAB026C0542CBDB6802F";
    const char *sig_bad_hex = "643D6F34902D9C7EC90CB0B2BCA36C47FA37165C0005CAB026C0542CBDB6803F";
    const char *e_hex = "010001";
    const char *n_hex = "AE1CD4DC432798D933779FBD46C6E1247F0CF1233595113AA51B450F18116115";

    char msg_hex[256];
    char *expected_hex = NULL;
    char *ok_hex = NULL;
    char *bad_hex = NULL;

    ascii_to_hex(msg_ascii, msg_hex, sizeof(msg_hex));

    BN_hex2bn(&n, n_hex);
    BN_hex2bn(&e, e_hex);
    BN_hex2bn(&s_ok, sig_ok_hex);
    BN_hex2bn(&s_bad, sig_bad_hex);
    BN_hex2bn(&m_expected, msg_hex);

    BN_mod_exp(m_from_sig_ok, s_ok, e, n, ctx);
    BN_mod_exp(m_from_sig_bad, s_bad, e, n, ctx);

    expected_hex = BN_bn2hex(m_expected);
    ok_hex = BN_bn2hex(m_from_sig_ok);
    bad_hex = BN_bn2hex(m_from_sig_bad);

    printf("Message ASCII = %s\n", msg_ascii);
    printf("Message hex   = %s\n", expected_hex);
    printf("\n");

    printf("[Given Signature]\n");
    printf("S hex         = %s\n", sig_ok_hex);
    printf("S^e mod n hex = %s\n", ok_hex);
    printf("Verification  = %s\n", (BN_cmp(m_from_sig_ok, m_expected) == 0) ? "VALID" : "INVALID");
    printf("\n");

    printf("[Corrupted Signature: last byte 2F -> 3F]\n");
    printf("S' hex        = %s\n", sig_bad_hex);
    printf("S'^e mod nhex = %s\n", bad_hex);
    printf("Verification  = %s\n", (BN_cmp(m_from_sig_bad, m_expected) == 0) ? "VALID" : "INVALID");

    OPENSSL_free(expected_hex);
    OPENSSL_free(ok_hex);
    OPENSSL_free(bad_hex);

    BN_free(n);
    BN_free(e);
    BN_free(s_ok);
    BN_free(s_bad);
    BN_free(m_expected);
    BN_free(m_from_sig_ok);
    BN_free(m_from_sig_bad);
    BN_CTX_free(ctx);
    return 0;
}
