#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("This is my ls program\n");
    printf("My real uid is: %d\n", getuid());
    printf("My effective uid is: %d\n", geteuid());
    return 0;
}
