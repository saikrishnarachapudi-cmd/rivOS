QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude

TARGET  := kernel.elf
MAPFILE := kernel.map
LDSCRIPT:= kernel.ld

# Object files (boot.o must stay first)
OBJS    := kernel/boot.o \
           kernel/terminal.o \
           kernel/proc_crea.o \
           kernel/mem_cpy.o \
           kernel/memset0.o \
           kernel/switch_context.o

.PHONY: all build run start clean

all: build

build: $(TARGET)

# Link all objects into the final ELF
$(TARGET): $(OBJS) $(LDSCRIPT)
	$(CC) $(CFLAGS) $(OBJS) -Wl,-T$(LDSCRIPT) -Wl,-Map=$(MAPFILE) -o $@

# Assemble both .S and .s files (the include dir holds struct.inc)
%.o: %.S include/struct.inc
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s include/struct.inc
	$(CC) $(CFLAGS) -c $< -o $@

run: start
start: $(TARGET)
	$(QEMU) -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel $(TARGET)

clean:
	rm -f $(OBJS) $(TARGET) $(MAPFILE)
