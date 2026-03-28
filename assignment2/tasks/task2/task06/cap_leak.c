#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void)
{
    int fd;

    fd = open("/etc/zzz", O_RDWR | O_APPEND);
    if (fd == -1) {
        printf("Cannot open /etc/zzz\n");
        exit(0);
    }

    sleep(1);
    setuid(getuid());

    if (fork()) {
        close(fd);
        wait(NULL);
        exit(0);
    } else {
        write(fd, "Malicious Data\n", 15);
        close(fd);
    }

    return 0;
}
