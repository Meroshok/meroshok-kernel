[bits 16]
[org 0x7c00]

start:
cli
xor ax, ax
mov es, ax
mov ss, ax
mov ds, ax
mov sp, 0x7c00
sti

disk_load_chs:
mov ax, 0x0202
mov bx, 0x8000
mov cx, 0x0002
xor dh, dh
int 0x13
jc error

xor ebx, ebx
mov edi, 0x7004
xor ecx, ecx
mov dword [0x7000], 0
memmap:
mov eax, 0xe820
mov edx, 0x534d4150 
mov ecx, 24

int 0x15
jc error

add edi, 24
inc dword [0x7000]

test ebx, ebx
jnz memmap

xor di, di
mov ax, 0xb800
mov es, ax
mov ax, 0x0f44
mov [es:di], ax

jmp 0x0000:0x8000

align 16
error:
cli
hlt
jmp $

times 510-($-$$) db 0x90
dw 0xaa55
