[bits 16]
[org 0x7C00]

start:
mov [disk_number], dl

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

check_extensions:
mov si, LBA_check
call print

mov ah, 0x41
mov bx, 0x55AA
mov dl, [disk_number]
int 0x13
jc disk_load_chs
cmp bx, 0xAA55
jne disk_load_chs

disk_load_lba:
mov si, msg_ok
call print

mov ah, 0x42
mov dl, [disk_number]
mov si, dap
int 0x13
jc disk_load_err

jmp disk_load_done

disk_load_chs:
mov si, msg_no
call print

;mov ah, 0x02	;read
;mov al, 0x02	;two sectors
;mov bx, 0x8000	;recording address
;mov ch, 0x00	;cylinder number
;mov cl, 0x02	;sector number
;mov dh, 0x00	;head number
;dl = device number
;int 0x13

mov ax, 0x0202
mov bx, 0x8000
mov cx, 0x0002
xor dh, dh
mov dl, [disk_number]
int 0x13
jc disk_load_err

disk_load_done:

cli 
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 0x1
mov cr0, eax

jmp 0x08:init_pm


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

disk_number db 0

align 4
dap:
db 0x10, 0, 0x02, 0
dw 0x8000, 0x0000
dq 1  


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

disk_load_err:
mov al, ah
call to_hex
mov [abs err_code], ax

mov si, err_msg
call print

mov si, err_code
call print

mov si, try_again
call print

xor ah, ah
int 0x16

xor ax, ax
mov dl, [abs disk_number]
int 0x13

jmp check_extensions

to_hex:
mov bl, al
and al, 0x0F
call hex_digit
mov ah, al
mov al, bl
shr al, 4
call hex_digit
ret

hex_digit:
add al, 0x30
cmp al, 0x39
jbe done
add al, 0x07
done:
ret

print:
mov ah, 0x0E
print_loop:
lodsb
cmp al, 0
je print_end
int 0x10
jmp print_loop
print_end:
ret

LBA_check: db "IS LBA SUPPORTED?: ", 0 
msg_ok: db "YES", 13, 10, 0
msg_no: db "No", 13, 10, 0
err_msg: db "Disk Err: 0x", 0
err_code: db "00", 13, 10, 0

try_again:
db "Retry...", 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55

