.code32
.extern vga_shell

.section .text
.global vga_clear
vga_clear:
    cld
    movl $0xB8000, %edi
    xorl %eax, %eax
    movl $1000, %ecx
    rep stosl
    jmp vga_shell

