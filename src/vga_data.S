
.section .data

.global vga_buffer_ptr
.global vga_row_remaining
.global vga_kb_flags

vga_buffer_ptr:
    .long 0xB8000

vga_row_remaining:
    .long 160

vga_kb_flags:
    .long 0

.section .rodata
.global keymap_lower
.global shift_upper
.global capslock_upper
.global capslock_shift

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
    .byte 0     # 1C enter
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