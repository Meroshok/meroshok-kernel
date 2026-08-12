.code32

.extern pmm_pdpt_addr
.extern pmm_pdpt_size
.extern pmm_page_dir_addr
.extern pmm_page_dir_size
.extern pmm_page_table_addr
.extern pmm_page_table_size
.extern kernel_start
.extern kernel_size

.extern kernel_memmap
.extern memmap_count

.section .text
.global prepare_memmap

prepare_memmap:
    movl 0x7004, %esi
    movl $kernel_memmap, %edi

    movl 0x7000, %ecx
    movl %ecx, %eax

    leal (%ecx,%ecx,2), %ecx
    shll $1, %ecx

    rep movsl

    movl %eax, %ecx
    xorl %ebp, %ebp
    movl $2, %ebx

    movl pmm_pdpt_addr, %eax
    movl pmm_pdpt_size, %edx
    call append_memmap_region

    movl pmm_page_dir_addr, %eax
    movl pmm_page_dir_size, %edx
    call append_memmap_region

    movl pmm_page_table_addr, %eax
    movl pmm_page_table_size, %edx
    call append_memmap_region

    movl $kernel_start, %eax
    movl $kernel_size, %edx
    call append_memmap_region

    movl %ecx, memmap_count

    ret

append_memmap_region:
    movl %eax, 0(%edi)
    movl %ebp, 4(%edi)

    movl %edx, 8(%edi)
    movl %ebp, 12(%edi)

    movl %ebx, 16(%edi)

    addl $24, %edi
    incl %ecx

    ret