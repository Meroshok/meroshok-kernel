#ifndef CONSOLE_H
#define CONSOLE_H

typedef struct {
    char* buffer;
    int width;
    int height;
    int row;
    int col;
} console_t;

void console_init(console_t* c, char* fb, int w, int h);
void console_putc(console_t* c, char ch);
void console_clear(console_t* c);
void console_scroll(console_t* c);
void console_write(console_t* c, const char* s);

#endif