[bits 64]
;[org 0x10000]
extern kernel_main
global start_kernel
start_kernel:
    mov rsp, 0x90000
    call kernel_main
    hlt