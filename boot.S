#define KERNEL_PHYS_ADDR 0x10000
#define KERNEL_SEGMENT 0x1000
#define KERNEL_OFFSET 0
#define MEMMAP_STRUCT_ADDR 0X8000
#define MEMMAP_COUNT_ADDR 0X7000

.code16
boot:
    cli
    xorw %ax, %ax
    movw %ax, %es
    movw %ax, %ss
    movw %ax, %ds
    movw $0x7C00, %sp
    sti

    movb %dl, disk
    call vgaclear

lba_check:
    movb $0x41, %ah
    movw $0x55AA, %bx
    movb disk, %dl
    int $0x13
    jc disk_err
    cmpw $0xAA55, %bx
    jne disk_err

    inb  $0x92, %al
    orb  $0x02, %al
    outb %al, $0x92

lba_kernel:
    movb $0x42, %ah
    movb disk, %dl 
    movw $dap_kernel, %si
    int $0x13
    jc disk_err

memmap:
    xorl %ebx, %ebx
    xorl %esi, %esi
    movl $MEMMAP_STRUCT_ADDR, %edi

.loop:
    xorw %ax, %ax
    movw %ax, %es
    movl $0xE820, %eax
    movl $0x534d4150, %edx
    movl $24, %ecx
    int $0x15
    jc memmap_err
    addl $24, %edi
    incl %esi
    testl %ebx, %ebx
    jnz .loop

    movl %esi, MEMMAP_COUNT_ADDR

    cli
    lgdt gdt_descriptor
    movl %cr0, %eax
    orl $1, %eax
    movl %eax, %cr0

    ljmp $0x08, $pm_init


.code32
pm_init:
    jmp KERNEL_PHYS_ADDR

.code16
vgaclear:
    pusha
    movw $0xB800, %ax
    movw %ax, %es
    xorw %di, %di
    cld
    xorl %eax, %eax
    movw $1000, %cx
    rep stosl
    popa
    ret

disk_err:
memmap_err:
    cli
    hlt

    disk: .byte 0

    dap_kernel:
    .byte 0x10
    .byte 0x00
    .word 4
    .word KERNEL_OFFSET
    .word KERNEL_SEGMENT
    .quad 1

    gdt_start:
    .quad 0
    .word 0xFFFF, 0x0000, 0x9A00, 0x00CF
    gdt_data:
    .word 0xFFFF, 0x0000, 0x9200, 0x00CF
    gdt_end:

    gdt_descriptor:
    .word gdt_end - gdt_start - 1
    .long gdt_start

.fill 510 - (. - boot), 1, 0
.word 0xAA55