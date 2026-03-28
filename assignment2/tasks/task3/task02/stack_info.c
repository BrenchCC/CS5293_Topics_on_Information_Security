/* stack_info.c */

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
    char dummy[BUFSIZE];
    char input[8] = "AAAA";

    memset(dummy, 0, sizeof(dummy));
    bof(input);
    return 0;
}
