#include "lib/console.h"

void kernel_main() {
    static console_t console = { (char*)0xB8000, 80, 25, 0, 0 };
    
    console_clear(&console);
    console_write(&console, "It works!");
    
    while(1);
}