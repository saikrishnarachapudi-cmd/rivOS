QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude
build: main.s
	$(CC) -r $(CFLAGS) $^ -o memory.o
test:
	riscv32-unknown-elf-gcc  test.c main.s test.s -Iinclude -o test.out -O0 -g3
	qemu-riscv32 -L /usr/riscv64-linux-gnu/ ./test.out