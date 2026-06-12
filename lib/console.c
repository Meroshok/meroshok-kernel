typedef struct __attribute__((packed)) {
    char* buffer;
    int width;
    int height;
    int row;
    int col;
} console_t;

void console_init(console_t* c, char* b, int w, int h) {
    c->buffer = b;
    c->width = w;
    c->height = h;
    c->row = 0;
    c->col = 0;
}

void console_scroll(console_t* c) {
    for (int y = 1; y < c->height; y++) {
        for (int x = 0; x < c->width; x++) {

            int from = (y * c->width + x) * 2;
            int to   = ((y - 1) * c->width + x) * 2;

            c->buffer[to]     = c->buffer[from];
            c->buffer[to + 1] = c->buffer[from + 1];
        }
    }

    int last = (c->height - 1) * c->width * 2;

    for (int x = 0; x < c->width; x++) {
        c->buffer[last + x * 2] = ' ';
        c->buffer[last + x * 2 + 1] = 0x07;
    }

    c->row--;
}

void console_putc(console_t* c, char ch) {

    if (ch == '\n') {
        c->col = 0;
        c->row++;
    } else {

        int index = (c->row * c->width + c->col) * 2;

        c->buffer[index] = ch;
        c->buffer[index + 1] = 0x0F;

        c->col++;
    }

    if (c->col >= c->width) {
        c->col = 0;
        c->row++;
    }

    if (c->row >= c->height) {
        console_scroll(c);
    }
}

void console_clear(console_t* c) {
    for (int i = 0; i < c->width * c->height; i++) {
        c->buffer[i * 2] = ' ';
        c->buffer[i * 2 + 1] = 0x07;
    }

    c->row = 0;
    c->col = 0;
}

void console_write(console_t* c, const char* s) {
    while (*s) {
        console_putc(c, *s++);
    }
}