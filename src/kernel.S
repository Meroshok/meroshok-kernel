.code32
.global kernel

.extern kernel_main
.extern pmm_init

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

    call pmm_init
    call kernel_main

    cli
    hlt