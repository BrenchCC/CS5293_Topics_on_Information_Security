/* env666.c */

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    char *shell;

    shell = getenv("MYSHELL");
    if (shell != NULL) {
        printf("%p\n", shell);
    }

    return 0;
}
