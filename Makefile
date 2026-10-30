QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude
#---------------------------
SUBDIRS = kernel/ kernel/Process/ kernel/Core/ kernel/Memory/ lib/
.PHONY: libs $(SUBDIRS) build

build: libs buildK
libs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

# Object files
OBJS    := kernel/Core/core.o kernel/Process/process.o lib/lib.o

# Build the kernel
buildK: kernel/boot.s
	$(CC) $(CFLAGS) kernel/boot.s $(OBJS) -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf
run: kernel.elf
	$(QEMU) -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel kernel.elf

clean:
	rm -f kernel.elf kernel.map
	find . -type f -name "*.o" -delete
