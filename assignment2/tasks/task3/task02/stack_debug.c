/* stack_debug.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef BUFSIZE
#define BUFSIZE 24
#endif

int bof(char *str)
{
    char buffer[BUFSIZE];
    printf("buffer=%p\n", buffer);
    printf("ret_addr_slot=%p\n", (char *)__builtin_frame_address(0) + 4);
    printf("offset=%ld\n", (long)(((char *)__builtin_frame_address(0) + 4) - buffer));

    strcpy(buffer, str);

    return 1;
}

int main(void)
{
    char str[517];
    FILE *badfile;
    char dummy[BUFSIZE];

    memset(dummy, 0, sizeof(dummy));
    printf("str=%p\n", str);
    printf("dummy=%p\n", dummy);

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
