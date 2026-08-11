.code32
.global kernel

#include "config.h"


.extern pmm_init
.extern vga_shell

.section .kernel, "ax"

kernel:
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    movl $0x90000, %esp
    cld

    movl $VGA_ADDR, VGA_BUFFER_PTR_ADDR
    movl $(VGA_ROW_SIZE / 2), VGA_ROW_REMAINING_ADDR
    
    call pmm_init
    call vga_shell

    cli
    hlt