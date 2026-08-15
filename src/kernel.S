.code32
#include "config.h"
.extern pmm_init
.extern vga_shell

.section .text
.global kernel
kernel:
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    movl $0x90000, %esp
    cld
    
    call pmm_init
    call vga_shell

    cli
    hlt