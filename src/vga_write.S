#include "config.h"
#include "asm_macros.h"

.global vga_write
vga_write:
    PUSH_GPRS
    pushl %ebp
    movl 32(%esp), %esi
    movb 36(%esp), %ah
    movl $40, %ebp

    movl VGA_BUFFER_PTR_ADDR, %edi
    movl VGA_ROW_REMAINING_ADDR, %ebx

.vga_loop:
    lodsb
    testb %al, %al
    jz .vga_exit

    cmpb $10, %al
    je .vga_newline

    cmpb $'%', %al
    je .vga_format

.vga_print:
    movw %ax, (%edi)
    addl $2, %edi
    decl %ebx
    jnz .vga_loop    

    movl $VGA_ROW_SIZE / 2, %ebx
    cmpl $(VGA_ADDR + VGA_SIZE), %edi
    jne .vga_loop

.vga_scroll:
    mov %esi, %ebx
    movl $(VGA_ADDR + VGA_ROW_SIZE), %esi
    movl $VGA_ADDR, %edi
    movl $(VGA_SIZE - VGA_ROW_SIZE) / 4, %ecx
    rep movsl

    movl %ebx, %esi
    movl %eax, %ebx
    
    xorl %eax, %eax
    movl $160 / 4, %ecx
    rep stosl

    movl %ebx, %eax
    movl $VGA_ROW_SIZE / 2, %ebx
    movl $(VGA_ADDR + VGA_SIZE - VGA_ROW_SIZE), %edi
    jmp .vga_loop

.vga_newline:
    shll $1, %ebx
    addl %ebx, %edi
    movl $VGA_ROW_SIZE / 2, %ebx

    cmpl $(VGA_ADDR + VGA_SIZE), %edi
    je .vga_scroll
    jmp .vga_loop
    
.vga_format:
    lodsb
    testb %al, %al 
    jz .vga_exit

    cmpb $'%', %al
    je .vga_print

    cmpb $'x', %al
    je .vga_x

    decl %esi
    jmp .vga_loop

.vga_x:
    movb %ah, %dh 
    movl (%esp, %ebp), %eax
    addl $4, %ebp

    movl $8, %ecx
    testl %eax, %eax
    jz .vga_x_loop
    roll $4, %eax

.vga_x_loop:
    movb %al, %dl
    andb $0x0F, %dl
    cmpb $10, %dl
    jl .vga_x_digit
    addb $'A'-10, %dl
    jmp .vga_x_emit
    
.vga_x_digit:
    addb $'0', %dl  

.vga_x_emit:
    movw %dx, (%edi)
    roll $4, %eax
    addl $2, %edi
    decl %ebx
    jnz .vga_x_next

    movl $VGA_ROW_SIZE / 2, %ebx
    cmpl $(VGA_ADDR + VGA_SIZE), %edi
    jne .vga_x_next

    movb %cl, %dl
    movl %esi, %ebx
    movl $(VGA_ADDR + VGA_ROW_SIZE), %esi
    movl $VGA_ADDR, %edi
    movl $(VGA_SIZE - VGA_ROW_SIZE) / 4, %ecx
    rep movsl

    movl %ebx, %esi
    movl %eax, %ebx
    xorl %eax, %eax
    movl $160 / 4, %ecx
    rep stosl
    movzbl %dl, %ecx
    movl %ebx, %eax
    movl $VGA_ROW_SIZE / 2, %ebx
    movl $(VGA_ADDR + VGA_SIZE - VGA_ROW_SIZE), %edi
.vga_x_next:
    loop .vga_x_loop
    movb %dh, %ah
    jmp .vga_loop

.vga_exit:
    movl %edi, VGA_BUFFER_PTR_ADDR
    movl %ebx, VGA_ROW_REMAINING_ADDR
    popl %ebp
    POP_GPRS
    ret
