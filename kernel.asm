[bits 64]
[org 0x8000]

kernel:
mov rdi, 0xB8000
mov rax, 0x2F4B2F4B2F4B2F4B 
mov [rdi], rax

jmp $
