#include <sys/types.h>
#include <unistd.h>

int main(void)
{
    char *argv[2];

    argv[0] = "/bin/sh";
    argv[1] = NULL;

    execve("/bin/sh", argv, NULL);
    return 0;
}
