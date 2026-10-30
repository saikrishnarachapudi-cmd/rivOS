QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11  -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld -nostdlib \
           -march=rv32ima_zicsr -Iinclude\
           #-O2 -fno-stack-protector -ffreestanding
build: mem_cpy.s memset0.s stdio.s
	$(CC) -r $(CFLAGS) $^ -o lib.o 