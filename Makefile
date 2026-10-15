QEMU=qemu-system-riscv32
# Path to clang and compiler flags
CC=clang  # Ubuntu users: use CC=clang
CFLAGS=-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32-unknown-elf -fuse-ld=lld -fno-stack-protector -ffreestanding -nostdlib -march=rv32imac_zicsr
SUBDIRS = $(wildcard */.)
#list all libraries here to link -----------------
LIBS = stdlib/stdlib.o
#---------------------------
.PHONY: libs $(SUBDIRS) build

build: libs buildK
libs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

# Build the kernel
buildK: kernel.S
	$(CC) $(CFLAGS) kernel.S $(LIBS) -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf

.PHONY:start
run: start
start:
	$(QEMU) -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel kernel.elf
clean:
	rm kernel.elf
	rm kernel.map