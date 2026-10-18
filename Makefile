QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude

LIBNAMES = terminal
LIBFILES = terminal/terminal.o
#---------------------------
.PHONY: libs $(SUBDIRS) build

build: libs buildK
libs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C -k $@

# Object files
OBJS    := kernel/boot.o user/terminal.o

# Build the kernel
buildK: kernel.S
	$(CC) $(CFLAGS) kernel.S $(LIBS) -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf
run: kernel.elf
	$(QEMU) -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel $(TARGET)

clean:
	rm -f kernel.elf kernel.map