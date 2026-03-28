#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    char *v[3];

    if (argc < 2) {
        printf("Please type a file name.\n");
        return 1;
    }

    v[0] = "/bin/cat";
    v[1] = argv[1];
    v[2] = NULL;

    execve(v[0], v, NULL);
    perror("execve");
    return 1;
}
