.extern vga_buffer_ptr
.extern vga_row_remaining
.extern vga_kb_flags
.extern keymap_lower
.extern shift_upper
.extern capslock_upper
.extern capslock_shift
.extern vga_clear

.code32
.section .text
.global vga_shell
vga_shell:
    movl vga_buffer_ptr, %edi
    movb vga_row_remaining, %dl
    movb vga_kb_flags, %dh

    movl $0x0000073E, (%edi)
    addl $4, %edi
    movl $0xF000, (%edi) 

    subb $4, %dl
    xorl %ebx, %ebx
    xorl %ebp, %ebp

.read:
    xorl %eax, %eax
    inb $0x64, %al
    testb $1, %al
    jz .read

    inb $0x60, %al

    cmpb $0x0E, %al
    je .backspace

    cmpb $0x1C, %al
    je .enter

    cmpb $0x2A, %al
    je .shift_press

    cmpb $0x36, %al
    je .shift_press

    cmpb $0xAA, %al
    je .shift_release

    cmpb $0xB6, %al
    je .shift_release

    cmpb $0x3A, %al
    je .caps_toggle

    cmpb $0x4B, %al
    je .arrow_left

    cmpb $0x4D, %al
    je .arrow_right

    testb $0x80, %al
    jnz .read

.select_keymap:
    movl $keymap_lower, %ecx
    cmpb $0, %dh
    cmove %ecx, %esi

    movl $capslock_upper, %ecx
    cmpb $1, %dh
    cmove %ecx, %esi

    movl $shift_upper, %ecx
    cmpb $2, %dh
    cmove %ecx, %esi

    movl $capslock_shift, %ecx
    cmpb $3, %dh
    cmove %ecx, %esi
    
    movb (%esi,%eax), %al

    testb %al, %al
    jz .read

.insert_char:
    cmpl %ebx, %ebp
    jnbe .print

    movl %ebx, %ecx
    subl %ebp, %ecx
    shrl $1, %ecx
    leal -2(%edi,%ebx), %esi
    leal (%edi,%ebx), %edi

    std
    rep movsw
    cld

    subl %ebp, %edi

.print:
    movb $0x07, %ah
    movw %ax, (%edi, %ebp)

    addl $2, %ebx
    addl $2, %ebp
    subb $2, %dl

    movw (%edi, %ebp), %ax
    movb $0xF0, %ah
    movw %ax, (%edi, %ebp)

    testb %dl, %dl
    jnz .read

    movb $160, %dl
    leal (%edi,%ebx), %eax
    
    cmpl $(0xB8000 + 4000), %eax
    jb .read

    cmpl $(4000 - 4), %ebx
    jae vga_clear

    movl $(0xB8000 + 160), %esi
    movl $0xB8000, %edi
    movl $(4000 - 160) / 4, %ecx
    rep movsl

    xorl %eax, %eax
    movl $160 / 4, %ecx
    rep stosl

    movl $(0xB8000 + 4000 - 160), %edi
    subl %ebx, %edi
    movb $160, %dl

    jmp .read

.backspace:
    testl %ebx, %ebx
    jz .read

    cmpl %ebx, %ebp
    jne .backspace_shift
    
    movw $0x0000, (%edi,%ebp)

    subl $2, %ebp
    subl $2, %ebx
    addb $2, %dl

    movw $0xF000, (%edi,%ebp)

    jmp .read

.backspace_shift:
    testl %ebp, %ebp
    jz .read

    subl $2, %ebp

    movl %ebx, %ecx
    subl %ebp, %ecx
    subl $2, %ecx

    shrl $1, %ecx

    leal 2(%edi,%ebp), %esi
    leal (%edi,%ebp), %edi

    cld
    rep movsw

    subl %ebx, %edi
    addl $2, %edi

    subl $2, %ebx
    addb $2, %dl

    movw $0x0F00, (%edi,%ebx)
    movw (%edi,%ebp), %ax
    movb $0xF0, %ah
    movw %ax, (%edi,%ebp)

    jmp .read

.enter:
    movw (%edi,%ebx), %ax
    notb %ah
    movw %ax, (%edi,%ebx)

    addl %ebx, %edi
    movzbl %dl, %ecx
    addl %ecx, %edi

    xorl %ebx, %ebx
    xorl %ebp, %ebp
    movb $160 - 4, %dl

    movl $0x0000073E, (%edi)
    addl $4, %edi
    movl $0xF000, (%edi)

    cmpl $(0xB8000 + 4000), %edi
    jae .scroll
    jmp .read

.scroll:
    movl $(0xB8000 + 160), %esi
    movl $0xB8000, %edi
    movl $(4000 - 160) / 4, %ecx
    rep movsl

    xorl %eax, %eax
    movl $160 / 4, %ecx
    rep stosl

    movl $(0xB8000 + 4000 - 160), %edi
    xorl %ebx, %ebx
    xorl %ebp, %ebp
    movl $0x0000073E, (%edi)
    addl $4, %edi
    movl $0xF000, (%edi)

    jmp .read

.shift_press:
    movzbl %dh, %eax
    btsl $0x01, %eax
    movb %al, %dh
    jmp .read

.shift_release:
    movzbl %dh, %eax
    btrl $0x01, %eax
    movb %al, %dh
    jmp .read

.caps_toggle:
    movzbl %dh, %eax
    btcl $0x00, %eax
    movb %al, %dh
    jmp .read

.arrow_left:
    testl %ebp, %ebp
    jz .read
    movw (%edi, %ebp), %ax
    movb $0x07, %ah
    movw %ax, (%edi, %ebp)
    subl $2, %ebp
    movw (%edi, %ebp), %ax
    movb $0xF0, %ah
    movw %ax, (%edi, %ebp)
    jmp .read

.arrow_right:
    cmpl %ebx, %ebp
    jae .read
    movw (%edi, %ebp), %ax
    movb $0x07, %ah
    movw %ax, (%edi, %ebp)
    addl $2, %ebp
    movw (%edi, %ebp), %ax
    movb $0xF0, %ah
    movw %ax, (%edi, %ebp)
    jmp .read
