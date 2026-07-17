#define PDPT_ADDR 0x00100000
#define PAGE_DIR_ADDR 0x00101000
#define PAGE_TABLE_ADDR 0x00105000
#define BITMAP_ADDR 0x00905000
#define MEMMAP_STRUCT_ADDR 0X8000
#define MEMMAP_COUNT_ADDR 0X7000

.global pmm_init
pmm_init:

pdpt_init:
    xorl %eax, %eax
    movl $PDPT_ADDR, %edi
    movl $(PAGE_DIR_ADDR + 3), %esi
    movl %esi, %edx
    movl $4, %ecx

pdpt_loop:
    movl %esi, 0(%edi)
    movl %eax, 4(%edi)
    addl $0x1000, %esi
    addl $8, %edi
    loop pdpt_loop


    movl $PAGE_DIR_ADDR, %edi
    movl $(PAGE_TABLE_ADDR + 3), %esi
    movl $(4 * 512), %ecx

pd_loop:
    movl %esi, 0(%edi)
    movl %eax, 4(%edi)
    addl $0x1000, %esi
    addl $8, %edi
    loop pd_loop


    movl $PAGE_TABLE_ADDR, %edi
    movl $3, %ebx
    movl $(4 * 512 * 512), %ecx

pt_loop:
    movl %ebx, 0(%edi)
    movl %eax, 4(%edi)
    addl $0x1000, %ebx
    addl $8, %edi
    loop pt_loop

    movl $PDPT_ADDR, %eax
    movl %eax, %cr3

    movl %cr4, %eax
    orl  $0x20, %eax
    movl %eax, %cr4

    movl %cr0, %eax
    orl  $0x80000000, %eax
    movl %eax, %cr0

    movl $MEMMAP_STRUCT_ADDR, %esi
    movl MEMMAP_COUNT_ADDR, %ecx
    xorl %eax, %eax
    xorl %ebx, %ebx

.find_max:
    movl 0(%esi), %edx
    movl 4(%esi), %ebp
    addl 8(%esi), %edx
    adcl 12(%esi), %ebp

    cmpl %ebp, %ebx
    jb .new_max
    ja .next
    cmpl %edx, %eax
    jae .next

.new_max:
    movl %edx, %eax
    movl %ebp, %ebx

.next:
    addl $24, %esi
    loop .find_max
    movl %eax, 0x7004
    movl %ebx, 0x7008
    shrdl $15, %ebx, %eax
    movl $0x200000, %ebx
    cmp  %ebx, %eax
    cmova %ebx, %eax
    movl %eax, 0x700C

    movl %eax, %ecx
    movl $BITMAP_ADDR, %edi
    movl %edi, 0x7010
    shrl $2, %ecx
    xorl %eax, %eax
    rep stosl
    
    movl %edi, 0x7014
    movl $MEMMAP_STRUCT_ADDR, %esi
    movl MEMMAP_COUNT_ADDR, %ecx
    movl $BITMAP_ADDR, %edi
.e820_loop:
    movl 16(%esi), %eax
    cmpl $1, %eax
    jne .skip_range
    movl 0(%esi), %eax
    movl 4(%esi), %ebx
    shrdl $12, %ebx, %eax
    movl 8(%esi), %edx
    movl 12(%esi), %ebp
    shrdl $12, %ebp, %edx

.mark_pages:
    testl %edx, %edx
    jz .skip_range
    bts %eax, (%edi)
    incl %eax
    decl %edx
    jmp .mark_pages

.skip_range:
    addl $24, %esi
    loop .e820_loop

reserve_boot_memory:
    movl $BITMAP_ADDR, %edi

    movl 0x7014, %ecx
    shrl $12, %ecx

.reserve:
    decl %ecx
    btr %ecx, (%edi)
    jnz .reserve



find_first_free:
    movl $BITMAP_ADDR, %esi
    xorl %eax, %eax

.nxt:
    movl (%esi), %ebx
    testl %ebx, %ebx
    jnz .found

    addl $32, %eax
    addl $4, %esi
    jmp .nxt

.found:
    bsfl %ebx, %ecx
    addl %ecx, %eax

    movl %eax, 0x7018

    shll $12, %eax
    movl %eax, 0x701C

    ret