#include "config.h"

.global vga_shell
vga_shell:
    movl VGA_BUFFER_PTR_ADDR, %edi
    xorl %ebx, %ebx 
    movl $0x00000F3E, (%edi)
    addl $4, %edi

    movl $VGA_ROW_SIZE, %ebp
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

    testb $0x80, %al
    jnz .read

    movl KB_FLAGS_ADDR, %edx

    movl $keymap_lower, %ecx
    cmpl $0, %edx
    cmove %ecx, %esi

    movl $capslock_upper, %ecx
    cmpl $1, %edx
    cmove %ecx, %esi

    movl $shift_upper, %ecx
    cmpl $2, %edx
    cmove %ecx, %esi

    movl $capslock_shift, %ecx
    cmpl $3, %edx
    cmove %ecx, %esi

    movb (%esi,%eax), %al

    testb %al, %al
    jz .read

    movb $0x0F, %ah
    movw %ax, (%edi, %ebx)

    movw $0xF000, 2(%edi, %ebx)

    addl $2, %ebx
    subl $2, %ebp

    testl %ebp, %ebp
    jnz .read

    movl $VGA_ROW_SIZE, %ebp
    
    leal (%edi,%ebx), %eax
    cmpl $(VGA_ADDR + VGA_SIZE), %eax
    jne .read

    jmp .scroll

.backspace:
    testl %ebx, %ebx
    jz .read

    xorl %eax, %eax
    movw %ax, (%edi, %ebx)

    subl $2, %ebx
    addl $2, %ebp

    movw %ax, (%edi, %ebx)

    movw -2(%edi, %ebx), %ax
    testw %ax, %ax
    jz .read

    movw (%edi, %ebx), %cx
    notb %ch
    movw %cx, -2(%edi, %ebx)

    jmp .read

.enter:
    notb %ah
    movb %ah, (%edi,%ebx)

    addl %ebx, %edi
    addl %ebp, %edi

    xorl %ebx, %ebx
    movl $VGA_ROW_SIZE, %ebp

    movl $0x00000F3E, -4(%edi)

    cmpl $(VGA_ADDR + VGA_SIZE), %edi
    jae .scroll
    jmp .read

.scroll:
    movl $(VGA_ADDR + VGA_ROW_SIZE), %esi
    movl $VGA_ADDR, %edi
    movl $(VGA_SIZE - VGA_ROW_SIZE) / 4, %ecx
    rep movsl

    xorl %eax, %eax
    movl $160 / 4, %ecx
    rep stosl

    movl $VGA_ROW_SIZE, %ebp
    movl $(VGA_ADDR + VGA_SIZE - VGA_ROW_SIZE), %edi
    jmp .read

.shift_press:
    btsl $0x01, KB_FLAGS_ADDR
    jmp .read

.shift_release:
    btrl $0x01, KB_FLAGS_ADDR
    jmp .read

.caps_toggle:
    btcl $0x00, KB_FLAGS_ADDR
    jmp .read

keymap_lower:
    .byte 0
    .byte 0     # 1
    .byte '1'   # 2
    .byte '2'   # 3
    .byte '3'   # 4
    .byte '4'   # 5
    .byte '5'   # 6
    .byte '6'   # 7
    .byte '7'   # 8
    .byte '8'   # 9
    .byte '9'   # A
    .byte '0'   # B
    .byte '-'   # C
    .byte '='   # D
    .byte 0     # E backspace
    .byte 0     # F tab

    .byte 'q'   # 10
    .byte 'w'   # 11
    .byte 'e'   # 12
    .byte 'r'   # 13
    .byte 't'   # 14
    .byte 'y'   # 15
    .byte 'u'   # 16
    .byte 'i'   # 17
    .byte 'o'   # 18
    .byte 'p'   # 19
    .byte '['   # 1A
    .byte ']'   # 1B
    .byte 0  # 1C enter
    .byte 0     # 1D

    .byte 'a'   # 1E
    .byte 's'   # 1F
    .byte 'd'   # 20
    .byte 'f'   # 21
    .byte 'g'   # 22
    .byte 'h'   # 23
    .byte 'j'   # 24
    .byte 'k'   # 25
    .byte 'l'   # 26
    .byte ';'   # 27
    .byte '\''  # 28
    .byte '`'   # 29
    .byte 0     # 2A l_shift
    .byte '\\'  # 2B

    .byte 'z'   # 2C
    .byte 'x'   # 2D
    .byte 'c'   # 2E
    .byte 'v'   # 2F
    .byte 'b'   # 30
    .byte 'n'   # 31
    .byte 'm'   # 32
    .byte ','   # 33
    .byte '.'   # 34
    .byte '/'   # 35
    .byte 0     # 36 r_shift
    .byte '*'   # 37
    .byte 0     # 38 r_alt    
    .byte ' '   # 39 space

.fill 256 - (. - keymap_lower), 1, 0

shift_upper:
    .byte 0
    .byte 0
    .byte '!'
    .byte '@'
    .byte '#'
    .byte '$'
    .byte '%'
    .byte '^'
    .byte '&'
    .byte '*'
    .byte '('
    .byte ')'
    .byte '_'
    .byte '+'
    .byte 8
    .byte 9

    .byte 'Q'
    .byte 'W'
    .byte 'E'
    .byte 'R'
    .byte 'T'
    .byte 'Y'
    .byte 'U'
    .byte 'I'
    .byte 'O'
    .byte 'P'
    .byte '{'
    .byte '}'
    .byte '\n'
    .byte 0

    .byte 'A'
    .byte 'S'
    .byte 'D'
    .byte 'F'
    .byte 'G'
    .byte 'H'
    .byte 'J'
    .byte 'K'
    .byte 'L'
    .byte ':'
    .byte '"'
    .byte '~'
    .byte 0
    .byte '|'

    .byte 'Z'
    .byte 'X'
    .byte 'C'
    .byte 'V'
    .byte 'B'
    .byte 'N'
    .byte 'M'
    .byte '<'
    .byte '>'
    .byte '?'
    .byte 0
    .byte '*'
    .byte 0
    .byte ' '

.fill 256 - (. - shift_upper), 1, 0

capslock_upper:
    .byte 0
    .byte 0     # 1
    .byte '1'   # 2
    .byte '2'   # 3
    .byte '3'   # 4
    .byte '4'   # 5
    .byte '5'   # 6
    .byte '6'   # 7
    .byte '7'   # 8
    .byte '8'   # 9
    .byte '9'   # A
    .byte '0'   # B
    .byte '-'   # C
    .byte '='   # D
    .byte 0     # E backspace
    .byte 0     # F tab

    .byte 'Q'
    .byte 'W'
    .byte 'E'
    .byte 'R'
    .byte 'T'
    .byte 'Y'
    .byte 'U'
    .byte 'I'
    .byte 'O'
    .byte 'P'
    .byte '['   # 1A
    .byte ']'   # 1B
    .byte '\n'  # 1C
    .byte 0     # 1D

    .byte 'A'
    .byte 'S'
    .byte 'D'
    .byte 'F'
    .byte 'G'
    .byte 'H'
    .byte 'J'
    .byte 'K'
    .byte 'L'

    .byte ';'   # 27
    .byte '\''  # 28
    .byte '`'   # 29
    .byte 0     # 2A l_shift
    .byte '\\'  # 2B

    .byte 'Z'
    .byte 'X'
    .byte 'C'
    .byte 'V'
    .byte 'B'
    .byte 'N'
    .byte 'M'
    .byte ','   # 33
    .byte '.'   # 34
    .byte '/'   # 35
    .byte 0     # 36 r_shift
    .byte '*'   # 37
    .byte 0     # 38 r_alt    
    .byte ' '   # 39 space

.fill 256 - (. - capslock_upper), 1, 0

capslock_shift:
    .byte 0
    .byte 0
    .byte '!'
    .byte '@'
    .byte '#'
    .byte '$'
    .byte '%'
    .byte '^'
    .byte '&'
    .byte '*'
    .byte '('
    .byte ')'
    .byte '_'
    .byte '+'
    .byte 8
    .byte 9

    .byte 'q'   # 10
    .byte 'w'   # 11
    .byte 'e'   # 12
    .byte 'r'   # 13
    .byte 't'   # 14
    .byte 'y'   # 15
    .byte 'u'   # 16
    .byte 'i'   # 17
    .byte 'o'   # 18
    .byte 'p'   # 19
    .byte '{'
    .byte '}'
    .byte '\n'
    .byte 0

    .byte 'a'   # 1E
    .byte 's'   # 1F
    .byte 'd'   # 20
    .byte 'f'   # 21
    .byte 'g'   # 22
    .byte 'h'   # 23
    .byte 'j'   # 24
    .byte 'k'   # 25
    .byte 'l'   # 26
    .byte ':'
    .byte '"'
    .byte '~'
    .byte 0
    .byte '|'

    .byte 'z'   # 2C
    .byte 'x'   # 2D
    .byte 'c'   # 2E
    .byte 'v'   # 2F
    .byte 'b'   # 30
    .byte 'n'   # 31
    .byte 'm'   # 32
    .byte '<'
    .byte '>'
    .byte '?'
    .byte 0
    .byte '*'
    .byte 0
    .byte ' '

.fill 256 - (. - capslock_shift), 1, 0
