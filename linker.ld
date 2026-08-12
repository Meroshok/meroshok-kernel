SECTIONS
{
    /DISCARD/ :
    {
        *(.note*)
        *(.comment*)
        *(.eh_frame*)
        *(.gnu*)
    }

    . = 0x10000;
    kernel_start = .;

    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
        *(COMMON)
    }

    kernel_end = .;
    kernel_size = kernel_end - kernel_start;
    kernel_sectors = (kernel_size + 511) / 512;
}