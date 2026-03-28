/* stack.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef BUFSIZE
#define BUFSIZE 24
#endif

int bof(char *str)
{
    char buffer[BUFSIZE];

    strcpy(buffer, str);

    return 1;
}

int main(void)
{
    char str[517];
    FILE *badfile;
    char dummy[BUFSIZE];

    memset(dummy, 0, sizeof(dummy));

    badfile = fopen("badfile", "r");
    if (badfile == NULL) {
        perror("fopen");
        return 1;
    }

    fread(str, sizeof(char), sizeof(str), badfile);
    fclose(badfile);

    bof(str);
    printf("Returned Properly\n");
    return 1;
}
