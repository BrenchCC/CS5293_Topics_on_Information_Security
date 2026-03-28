/* retlib.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef BUFSIZE
#define BUFSIZE 22
#endif

static void *keep_system = (void *)system;
static void *keep_exit = (void *)exit;

int bof(FILE *badfile)
{
    char buffer[BUFSIZE];

    if (keep_system == NULL || keep_exit == NULL) {
        return 0;
    }

    fread(buffer, sizeof(char), 300, badfile);
    return 1;
}

int main(void)
{
    FILE *badfile;
    char dummy[BUFSIZE * 5];

    memset(dummy, 0, sizeof(dummy));

    badfile = fopen("badfile", "r");
    if (badfile == NULL) {
        perror("fopen");
        return 1;
    }

    bof(badfile);
    printf("Returned Properly\n");
    fclose(badfile);
    return 1;
}
