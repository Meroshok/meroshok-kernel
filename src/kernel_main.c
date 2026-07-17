#include "vga_print.h"

typedef struct __attribute__((packed)) {
    unsigned int base_low;
    unsigned int base_high;

    unsigned int length_low;
    unsigned int length_high;

    unsigned int type;
    unsigned int attributes;
} mem_t;

void kernel_main() {
    mem_t *m = (mem_t*)0x8000;
    int count = *(int*)0x7000;

    vga_print("==============================================================================\n", 0, 8);

    vga_print(" ", 0, 15);

    vga_print("Base Address", 0, 11);
    vga_print("          | ", 0, 8);

    vga_print("Length", 0, 10);
    vga_print("                | ", 0, 8);

    vga_print("Type", 0, 14);
    vga_print("\n", 0, 15);

    vga_print("==============================================================================\n", 0, 8);

    for (int i = 0; i < count; i++) {
        mem_t *current = &m[i];

        vga_print("0x%x %x", 0, 15,
                current->base_high,
                current->base_low);

        vga_print("    | ", 0, 8);

        vga_print("0x%x %x", 0, 15,
                current->length_high,
                current->length_low);

        vga_print("   | ", 0, 8);

        switch (current->type) {
            case 1: vga_print("Usable  ",   0, 10); break;
            case 2: vga_print("Reserved",   0, 12); break;
            case 3: vga_print("ACPI    ",   0, 11); break;
            case 4: vga_print("NVS     ",   0, 13); break;
            case 5: vga_print("Bad     ",   0,  4); break;
            default: 
                vga_print("0x%x", 0, 15, current->type);
        }

        vga_print("\n", 0, 15);
    }

    vga_print("==============================================================================\n", 0, 8);

    vga_print("==============================================================================\n", 0, 8);

    vga_print("Memory information\n", 0, 14);

    vga_print("Entries        : 0x%x\n", 0, 15, count);
    vga_print("Bitmap         : 0x%x\n", 0, 15, *(unsigned int*)0x7010);
    vga_print("Bitmap end     : 0x%x\n", 0, 15, *(unsigned int*)0x7014);
    vga_print("Highest addr   : 0x%x %x\n", 0, 15, *(unsigned int*)0x7008, *(unsigned int*)0x7004);
    vga_print("Total pages    : 0x%x\n", 0, 15, *(unsigned int*)0x700C);
    vga_print("First free page : 0x%x\n", 0, 15, *(unsigned int*)0x7018);
    vga_print("First free addr : 0x%x\n", 0, 15, *(unsigned int*)0x701C);
    vga_print("==============================================================================\n", 0, 8);
    
    vga_print("Bitmap:\n", 0, 15);

    // unsigned int *bitmap = (unsigned int *)0x00905000;

    // for (int i = 0; i < 100; i++) {
    //     vga_print("[%x] = 0x%x\n", 0, 15, i, bitmap[i]);
    // }
    while(1) {} 
}
