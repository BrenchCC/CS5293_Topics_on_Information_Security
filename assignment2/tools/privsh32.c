#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    char *new_argv[argc + 2];
    int i;

    if (setuid(0) != 0) {
        perror("setuid");
    }

    if (argc < 2) {
        char *fallback_argv[] = {"bash", "-p", NULL};
        execv("/usr/bin/bash", fallback_argv);
        perror("execv");
        return 1;
    }

    new_argv[0] = "bash";
    new_argv[1] = "-p";
    for (i = 1; i < argc; i++) {
        new_argv[i + 1] = argv[i];
    }
    new_argv[argc + 1] = NULL;

    execv("/usr/bin/bash", new_argv);
    perror("execv");
    return 1;
}
