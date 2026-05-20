[bits 16]
[org 0x7C00]

start:
mov [BOOT_DRIVE], dl
    
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

mov bx, 0x8000
mov dh, 2
mov dl, [BOOT_DRIVE]
call disk_load

cli 
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 0x1
mov cr0, eax

jmp 0x08:init_pm

disk_load:
push dx
mov ah, 0x02
mov al, dh
xor ch, ch
xor dh, dh
mov cl, 0x02
int 0x13
jc disk_error
pop dx
ret

disk_error:
mov ax, 0x0E45
int 0x10
jmp $

BOOT_DRIVE db 0

[bits 32]
init_pm:
mov ax, 0x10
mov ds, ax
mov es, ax
mov ss, ax
    
mov esp, 0x90000

mov edi, 0x1000
mov cr3, edi
xor eax, eax
mov ecx, 4096
rep stosd

mov dword [0x1000], 0x2003
mov dword [0x2000], 0x3003
mov dword [0x3000], 0x4003

mov edi, 0x4000
mov eax, 0x00000003
mov ecx, 512

.fill_pt:
mov [edi], eax
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

mov eax, cr0
or eax, 1 << 31
mov cr0, eax

lgdt [gdt64_descriptor]
jmp 0x08:init_lm

[bits 64]
init_lm:
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
   
jmp 0x8000

align 8
gdt_start:
dq 0x0
dq 0x00cf9a000000ffff
dq 0x00cf92000000ffff
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

align 8
gdt64_start:
dq 0x0
dq 0x00af9a000000ffff
dq 0x00cf92000000ffff
gdt64_end:

gdt64_descriptor:
dw gdt64_end - gdt64_start - 1
dd gdt64_start

times 510-($-$$) db 0
dw 0xAA55

