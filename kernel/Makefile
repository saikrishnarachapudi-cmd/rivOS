QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude

build: boot.s main.s 1st_proc.s 2nd_proc.s 3rd_proc.s
	$(CC) -r $(CFLAGS) $^ -o boot.o
