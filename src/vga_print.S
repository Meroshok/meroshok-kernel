.global vga_print
vga_print:
    # pushl %ebp
    # movl %esp, %ebp
    pusha

    # movl 8(%ebp), %esi
    # movb 12(%ebp), %ah
    # shlb $4, %ah
    # addb 16(%ebp), %ah

    movl 36(%esp), %esi
    movb 40(%esp), %ah
    shlb $4, %ah
    addb 44(%esp), %ah
    movl $48, %ebp

    movl buf, %edi
    movl col, %ebx
    decl %esi
.main_loop:
    incl %esi
    movb (%esi), %al
    testb %al, %al
    jz .end

    cmpb $'%', %al
    je .is_format

    cmpb $10, %al
    je .newline
.print:
    movw %ax, (%edi)
    addl $2, %edi
    addl $2, %ebx
    cmpl $160, %ebx
    jl .main_loop
.newline:
    movl $160, %edx
    subl %ebx, %edx
    addl %edx, %edi
    xorl %ebx, %ebx

    cmpl $0xB8000 + 4000, %edi
    jne .main_loop
.scroll:
    mov %esi, %ebx
    movl $0xB8000 + 160, %esi
    movl $0xB8000, %edi
    movl $(4000 - 160) / 4, %ecx
    rep movsl

    movl %eax, %edx
    xorl %eax, %eax
    movl $160 / 4, %ecx
    rep stosl

    movl %edx, %eax
    movl %ebx, %esi
    xorl %ebx, %ebx
    movl $(0xb8000 + 4000 - 160), %edi
    jmp .main_loop

.is_format:
    incl %esi
    movb (%esi), %al
    testb %al, %al 
    jz .end

    cmpb $'%', %al
    je .print

    cmpb $10, %al
    je .newline

    cmpb $'x', %al
    je .do_hex

    jmp .print
.do_hex:
    movb %ah, %dh 
    movl (%esp, %ebp), %eax
    addl $4, %ebp
    addl $16, %ebx
    movl $8, %ecx
    testl %eax, %eax
    jz .hex_loop

    roll $4, %eax
.hex_loop:
    movb %al, %dl
    andb $0x0F, %dl

    cmpb $10, %dl
    jl .is_digit
    addb $'A'-10, %dl
    jmp .print_digit
.is_digit:
    addb $'0', %dl    

.print_digit:
    movw %dx, (%edi)
    addl $2, %edi
    roll $4, %eax
    loop .hex_loop
    movb %dh, %ah
    jmp .main_loop

.end:
    movl %edi, buf
    movl %ebx, col
    popa
    # popl %ebp
    ret

buf: .long 0xB8000
col: .long 0