CC = x86_64-elf-gcc
AS = nasm
LD = x86_64-elf-ld

CFLAGS = -ffreestanding -mno-red-zone -fno-stack-protector -m64 -O2 -c
LDFLAGS = -T linker.ld --oformat binary

all: os.bin

boot.bin: boot.asm
	$(AS) -f bin boot.asm -o boot.bin

kernel_entry.bin: kernel_entry.asm
	$(AS) -f bin kernel_entry.asm -o kernel_entry.bin

kernel.o: kernel.asm
	$(AS) -f elf64 kernel.asm -o kernel.o

kernel_main.o: kernel_main.c
	$(CC) $(CFLAGS) kernel_main.c -o kernel_main.o

lib/console.o: lib/console.c
	$(CC) $(CFLAGS) lib/console.c -o lib/console.o

kernel.bin: kernel.o kernel_main.o lib/console.o
	$(LD) $(LDFLAGS) -o kernel.bin kernel.o kernel_main.o lib/console.o
	truncate -s 1024 kernel.bin

os.bin: boot.bin kernel_entry.bin kernel.bin
	cat boot.bin kernel_entry.bin kernel.bin > os.bin

run: os.bin
	qemu-system-x86_64 -drive format=raw,file=os.bin

clean:
	rm -f *.bin *.o lib/*.o