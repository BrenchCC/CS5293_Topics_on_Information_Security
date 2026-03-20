#include <stdio.h>
#include <string.h>

unsigned char X[200] = {[0 ... 199] = 0x41};
unsigned char Y[200] = {[0 ... 199] = 0x41};

int main(void)
{
    if (memcmp(X, Y, 128) == 0) {
        printf("Benign branch executed: first 128 bytes of X and Y are equal\n");
    } else {
        printf("Malicious branch executed: first 128 bytes of X and Y are different\n");
    }

    printf("X first 16 bytes: ");
    for (int i = 0; i < 16; i++) {
        printf("%02x", X[i]);
    }
    printf("\n");

    printf("Y first 16 bytes: ");
    for (int i = 0; i < 16; i++) {
        printf("%02x", Y[i]);
    }
    printf("\n");

    return 0;
}
