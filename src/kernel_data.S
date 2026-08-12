.code32

.section .rodata

.global pmm_pdpt_addr
.global pmm_pdpt_size

.global pmm_page_dir_addr
.global pmm_page_dir_size

.global pmm_page_table_addr
.global pmm_page_table_size


pmm_pdpt_addr:
    .long 0x00100000

pmm_pdpt_size:
    .long 0x00001000


pmm_page_dir_addr:
    .long 0x00101000

pmm_page_dir_size:
    .long 0x00004000


pmm_page_table_addr:
    .long 0x00105000

pmm_page_table_size:
    .long 0x00800000


.section .bss

.align 16
.global kernel_memmap
kernel_memmap:
    .skip 24 * 128

.align 16
.global memmap_count
memmap_count:
    .long 0