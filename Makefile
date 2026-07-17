CC = x86_64-elf-gcc
LD = x86_64-elf-ld
OBJCOPY = x86_64-elf-objcopy

ASFLAGS = -c -m32 -ffreestanding
CFLAGS  = -m32 -ffreestanding -O2 -Wall -Iinclude
LDFLAGS = -m elf_i386 -T linker.ld --build-id=none

BUILD_DIR = build
SRC_DIR = src

KERNEL_OBJS = \
	$(BUILD_DIR)/kernel.o \
	$(BUILD_DIR)/kernel_main.o \
	$(BUILD_DIR)/pmm.o \
	$(BUILD_DIR)/vga_print.o

all: os.img

build:
	mkdir -p build

$(BUILD_DIR)/boot.bin: boot.S | $(BUILD_DIR)
	$(CC) $(ASFLAGS) boot.S -o $(BUILD_DIR)/boot.o
	$(LD) -m elf_i386 \
    -Ttext 0x7C00 \
    -e boot \
    --oformat elf32-i386 \
    --build-id=none \
    build/boot.o \
    -o build/boot.elf
	$(OBJCOPY) \
    -O binary \
    -R .note.gnu.property \
    -R .note.gnu.build-id \
    -R .comment \
    $(BUILD_DIR)/boot.elf \
    $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.bin: $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) $(KERNEL_OBJS) -o $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/kernel.bin

os.img: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cp $(BUILD_DIR)/boot.bin os.img
	cat $(BUILD_DIR)/kernel.bin >> os.img

run: os.img
	qemu-system-x86_64 -drive format=raw,file=os.img

clean: 
	rm -rf $(BUILD_DIR)