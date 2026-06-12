OUTPUT_FORMAT(elf64-x86-64)
ENTRY(start_kernel)

SECTIONS {
    . = 0x10000;
    .text : { *(.text) }
    .data : { *(.data) }
    .rodata : { *(.rodata) }
    .bss : { 
        *(.bss) 
        *(COMMON)
    }
}