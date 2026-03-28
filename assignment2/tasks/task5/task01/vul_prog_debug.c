#include <stdio.h>
#include <stdlib.h>

#define SECRET1 0x44
#define SECRET2 0x55

int main(int argc, char *argv[])
{
    char user_input[100];
    int *secret;
    int int_input;
    int a, b, c, d;

    a = 0x11111111;
    b = 0x22222222;
    c = 0x33333333;
    d = 0x44444444;

    secret = (int *)malloc(2 * sizeof(int));
    if (secret == NULL) {
        perror("malloc");
        return 1;
    }

    secret[0] = SECRET1;
    secret[1] = SECRET2;

    printf("The variable secret's address is 0x%08x (on stack)\n", (unsigned int)&secret);
    printf("The variable secret's value is 0x%08x (on heap)\n", (unsigned int)secret);
    printf("secret[0]'s address is 0x%08x (on heap)\n", (unsigned int)&secret[0]);
    printf("secret[1]'s address is 0x%08x (on heap)\n", (unsigned int)&secret[1]);
    printf("&int_input = 0x%08x\n", (unsigned int)&int_input);
    printf("user_input = 0x%08x\n", (unsigned int)user_input);
    printf("&a = 0x%08x, &b = 0x%08x, &c = 0x%08x, &d = 0x%08x\n",
        (unsigned int)&a, (unsigned int)&b, (unsigned int)&c, (unsigned int)&d);
    printf("Please enter a decimal integer\n");
    scanf("%d", &int_input);
    printf("Please enter a string\n");
    scanf("%99s", user_input);

    printf(user_input);
    printf("\n");

    printf("The original secrets: 0x%x -- 0x%x\n", SECRET1, SECRET2);
    printf("The new secrets: 0x%x -- 0x%x\n", secret[0], secret[1]);

    free(secret);
    return 0;
}
