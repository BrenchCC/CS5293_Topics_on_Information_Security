#include <stdio.h>
#include <stdlib.h>

#define LEN 32

int main(void)
{
    FILE *random = fopen("/dev/urandom", "rb");
    unsigned char key[LEN];
    int i = 0;

    if (random == NULL) {
        fprintf(stderr, "Failed to open /dev/urandom\n");
        return 1;
    }

    if (fread(key, sizeof(unsigned char), LEN, random) != LEN) {
        fclose(random);
        fprintf(stderr, "Failed to read 256-bit key\n");
        return 1;
    }
    fclose(random);

    printf("Generated 256-bit key (hex) = ");
    for (i = 0; i < LEN; i++) {
        printf("%02x", key[i]);
    }
    printf("\n");

    return 0;
}
