/* retlib_debug.c */

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
    char *shell = getenv("MYSHELL");

    if (keep_system == NULL || keep_exit == NULL) {
        return 0;
    }

    printf("shell=%p\n", shell);
    printf("buffer=%p\n", buffer);
    printf("saved_ebp=%p\n", __builtin_frame_address(0));
    printf("ret_slot=%p\n", (char *)__builtin_frame_address(0) + 4);
    printf("arg_slot=%p\n", (char *)__builtin_frame_address(0) + 8);
    printf("ret_offset=%ld\n", (long)(((char *)__builtin_frame_address(0) + 4) - buffer));
    printf("arg_offset=%ld\n", (long)(((char *)__builtin_frame_address(0) + 8) - buffer));

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
