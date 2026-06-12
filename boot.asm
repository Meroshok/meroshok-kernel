[bits 16]
[org 0x7C00]

cli
xor ax, ax
mov es, ax
mov ss, ax
mov ds, ax
mov sp, 0x7C00
sti

mov [disk_number], dl
call tmclear

lba_check:
mov ah, 0x41
mov bx, 0x55AA
mov dl, [disk_number]
int 0x13
jc no_lba

mov dl, [disk_number]

lba_kernel_entry:
    mov si, dap_kernel_entry
    mov ah, 0x42
    int 0x13
    jc disk_load_err

lba_kernel:
    mov si, dap_kernel
    mov ah, 0x42
    int 0x13
    jc disk_load_err
    jmp memmap

no_lba:
mov dl, [disk_number]
xor dh, dh

chs_kernel_entry:
    mov bx, 0x8000
    mov ax, 0x0201
    mov cx, 0x0001
    int 0x13
    jc disk_load_err
chs_kernel:
    mov bx, 0x1000
    mov ax, 0x0202
    mov cx, 0x0003
    int 0x13
    jc disk_load_err

memmap:
    xor ebx, ebx
    mov edi, 0x7004
    xor esi, esi
.loop:
    mov eax, 0xE820
    mov edx, 0x534d4150 
    mov ecx, 24
    int 0x15
    jc memmap_err
    add edi, 24
    inc esi
    test ebx, ebx
    jnz .loop
    mov [0x7000], esi

jmp 0x0000:0x8000

disk_load_err:
    mov si, msg_disk_err
    call print
    cli
    hlt

memmap_err:
    mov si, msg_mem_err
    call print
    cli
    hlt

print:
    pusha
    mov ax, 0xB800
    mov es, ax
    cld

    mov di, [print_index]
    mov bx, [print_col]
    mov ah, 0x07
.loop:
    lodsb
    test al, al
    jz .end
    cmp al, 10
    je .newline
    stosw
    add bx, 2
    cmp bx, 160
    jb .loop
.newline:
    sub di, bx
    add di, 160
    xor bx, bx
    cmp di, 4000
    jb .loop
    xor di, di
    call tmclear
    jmp .loop
.end:
    mov [print_index], di
    mov [print_col], bx
    popa
    ret

tmclear:
    pusha
    mov ax, 0xB800
    mov es, ax
    xor di, di
    cld
    mov eax, 0
    mov cx, 500
    rep stosd
    popa
    ret

align 16
dap_kernel_entry:
    db 0x10
    db 0x00
    dw 0x0001
    dw 0x8000
    dw 0x0000
    dq 1

dap_kernel:
    db 0x10
    db 0x00
    dw 0x0002
    dw 0x0000
    dw 0x1000
    dq 2

msg_disk_err: db "BOOT ERROR: Disk read failed", 0
msg_mem_err: db "BOOT ERROR: Memory map failed", 0
disk_number db 0
print_index dw 0
print_col dw 0

times 510-($-$$) db 0x00
dw 0xAA55