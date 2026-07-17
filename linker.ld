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
    .kernel : {
        *(.kernel)
    }
}