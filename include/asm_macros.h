#define PUSH_GPRS \
    pushl %eax; \
    pushl %ecx; \
    pushl %edx; \
    pushl %ebx; \
    pushl %esi; \
    pushl %edi

#define POP_GPRS \
    popl %edi; \
    popl %esi; \
    popl %ebx; \
    popl %edx; \
    popl %ecx; \
    popl %eax

    