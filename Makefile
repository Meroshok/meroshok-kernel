CC = x86_64-elf-gcc
LD = x86_64-elf-ld
OBJCOPY = x86_64-elf-objcopy

ASFLAGS = -c -m32 -ffreestanding -Iinclude
CFLAGS  = -m32 -ffreestanding -O2 -Wall -Iinclude
LDFLAGS = -m elf_i386 -T linker.ld --build-id=none

BUILD_DIR = build
SRC_DIR = src

KERNEL_OBJS = \
    $(BUILD_DIR)/kernel.o \
    $(BUILD_DIR)/kernel_data.o \
    $(BUILD_DIR)/prepare_memmap.o \
    $(BUILD_DIR)/pmm.o \
    $(BUILD_DIR)/vga_write.o \
    $(BUILD_DIR)/vga_shell.o \
    $(BUILD_DIR)/vga_clear.o

all: os.img

build:
	mkdir -p build

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S | $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/vga_shell_cmd/%.S | $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.bin: $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) $(KERNEL_OBJS) -o $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/kernel.bin boot.S | $(BUILD_DIR)
	@size=$$(stat -c%s $(BUILD_DIR)/kernel.bin); \
	sectors=$$(( (size + 511) / 512 )); \
	$(CC) $(ASFLAGS) boot.S -o $(BUILD_DIR)/boot.o; \
	$(LD) -m elf_i386 \
		-Ttext 0x7C00 \
		-e boot \
		--defsym kernel_sectors=$$sectors \
		--build-id=none \
		$(BUILD_DIR)/boot.o \
		-o $(BUILD_DIR)/boot.elf
	$(OBJCOPY) \
		-O binary \
		-R .note.gnu.property \
		-R .note.gnu.build-id \
		-R .comment \
		$(BUILD_DIR)/boot.elf \
		$(BUILD_DIR)/boot.bin

os.img: $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cp $(BUILD_DIR)/boot.bin os.img
	cat $(BUILD_DIR)/kernel.bin >> os.img

run: os.img
	qemu-system-x86_64 -drive format=raw,file=os.img

clean:
	rm -rf $(BUILD_DIR)