[bits 16]
[org 0x8000]
default rel
start:
cli
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 1
mov cr0, eax

jmp 0x08:init_pm

[bits 32]
init_pm:
mov ax, 0x10
mov es, ax
mov ss, ax
mov ds, ax
mov fs, ax
mov gs, ax

mov esp, 0x90000

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

fill_pt:
mov dword [edi], eax
add dword [edi+4], 0
add eax, 0x1000
add edi, 8
loop fill_pt

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
jmp 0x08:init_lm

align 16
gdt_start:
dq 0x0
dq 0x00cf9a000000ffff
dq 0x00cf92000000ffff
gdt_end:

align 16
gdt_descriptor:
dw gdt_end - gdt_start - 1
dd gdt_start

align 16
gdt64_start:
dq 0x0
dq 0x00af9a000000ffff
dq 0x00af92000000ffff
gdt64_end:

align 16
gdt64_descriptor:
dw gdt64_end - gdt64_start - 1
dd gdt64_start

[bits 64]
init_lm:
mov rsp, 0x90000
mov rax, 0x0f410f410f410f41
mov rdi, 0xb8000
mov [rdi], rax

mov rsi, 0x7004
mov ecx, [rsi-4]

find:
mov eax, [rsi + 16]
cmp eax, 1
jne next

mov rax, [rsi]
mov rbx, [rsi+8]
cmp rbx, 0x100000
jb next

mov [heap_ptr], rax
add rax, rbx
mov [heap_end], rax

jmp done

next:
add rsi, 24
loop find

done:

mov rax, 0x0f410f410f410f41
mov rdi, 0xb8008
mov [rdi], rax

jmp $

heap_ptr dq 0
heap_end dq 0

times 1024-($-$$) db 0x90
