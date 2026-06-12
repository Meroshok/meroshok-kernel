[bits 16]
[org 0x8000]

cli
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp 0x08:init_pm

align 16
gdt_start:
dq 0x0
dq 0x00CF9A000000FFFF
dq 0x00CF92000000FFFF
gdt_end:

align 16
gdt_descriptor:
dw gdt_end - gdt_start - 1
dd gdt_start
align 16

[bits 32]
init_pm:
mov ax, 0x10
mov es, ax
mov ss, ax
mov ds, ax
mov fs, ax
mov gs, ax

mov edi, 0x1000
xor eax, eax
mov ecx, 4096
rep stosd

mov dword [0x1000], 0x2003
mov dword [0x1004], 0 
mov dword [0x2000], 0x3003
mov dword [0x2004], 0
mov dword [0x3000], 0x4003
mov dword [0x3004], 0

mov edi, 0x4000
mov eax, 0x00000003
mov ecx, 512

.fill_pt:
    mov dword [edi], eax
    add dword [edi+4], 0
    add eax, 0x1000
    add edi, 8
    loop .fill_pt

mov eax, cr4
or eax, 1 << 5
mov cr4, eax

mov ecx, 0xC0000080
rdmsr
or eax, 1 << 8
wrmsr

mov eax, 0x1000
mov cr3, eax

mov eax, cr0
or eax, 1 << 31
mov cr0, eax


lgdt [gdt64_descriptor]
jmp 0x08:0x10000

align 16
gdt64_start:
dq 0x0
dq 0x00AF9A000000FFFF
dq 0x00AF92000000FFFF
gdt64_end:

align 16
gdt64_descriptor:
dw gdt64_end - gdt64_start - 1
dd gdt64_start

times 512-($-$$) db 0x00
