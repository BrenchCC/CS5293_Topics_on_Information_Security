#include <stdio.h>

unsigned int sleep(unsigned int seconds)
{
    (void)seconds;
    printf("I am not sleeping!\n");
    return 0;
}
