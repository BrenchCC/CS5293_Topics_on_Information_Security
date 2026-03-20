#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define KEYSIZE 16

int main(int argc, char **argv)
{
    int i = 0;
    unsigned char key[KEYSIZE];
    long long now = (long long)time(NULL);
    int use_srand = 1;

    if (argc > 1 && strcmp(argv[1], "--no-srand") == 0) {
        use_srand = 0;
    }

    printf("time(NULL) = %lld\n", now);
    printf("mode = %s\n", use_srand ? "with_srand_time" : "without_srand");

    if (use_srand) {
        srand((unsigned int)now);
    }

    for (i = 0; i < KEYSIZE; i++) {
        key[i] = (unsigned char)(rand() % 256);
        printf("%02x", key[i]);
    }
    printf("\n");

    return 0;
}
