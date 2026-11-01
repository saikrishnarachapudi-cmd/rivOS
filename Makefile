QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld -nostdlib \
           -march=rv32ima_zicsr -Iinclude\
		   #-O2 -fno-stack-protector -ffreestanding
#---------------------------
SUBDIRS = kernel/ kernel/Process/ kernel/Core/ kernel/Memory/ kernel/lib/ kernel/Memory
.PHONY: libs $(SUBDIRS)

build: libs buildK
libs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

# Object files
OBJS    := kernel/Core/core.o kernel/Process/process.o kernel/lib/lib.o kernel/boot.o kernel/Memory/memory.o

# Build the kernel
buildK: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf
run: kernel.elf
	$(QEMU) -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel kernel.elf
host: kernel.elf
	$(QEMU) -gdb tcp::9000 -S -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel kernel.elf

clean:
	rm -f kernel.elf kernel.map
	find . -type f -name "*.o" -delete
