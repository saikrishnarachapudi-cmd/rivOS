QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude

TARGET  := kernel.elf
MAPFILE := kernel.map
LDSCRIPT:= kernel.ld

# Object files
OBJS    := kernel/boot.o user/terminal.o

.PHONY: all build run start clean

all: build

build: $(TARGET)

# Link all objects into the final ELF
$(TARGET): $(OBJS) $(LDSCRIPT)
	$(CC) $(CFLAGS) $(OBJS) -Wl,-T$(LDSCRIPT) -Wl,-Map=$(MAPFILE) -o $@

# Pattern rule to assemble/compile .S files into .o
%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

run: start
start: $(TARGET)
	$(QEMU) -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel $(TARGET)

clean:
	rm -f $(OBJS) $(TARGET) $(MAPFILE)