QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf  -nostdlib \
           -march=rv32imac_zicsr -Iinclude\
           #-O2 -fno-stack-protector -ffreestanding
build: assembleEach combine
assembleEach: panic.s terminal.s trap_dispatch.s trap.s
	$(CC) -c $(CFLAGS) $^
combine: panic.o terminal.o trap_dispatch.o trap.o
	$(CC) $(CFLAGS) -fuse-ld=lld -r $^ -o core.o
testTerminal: test1.s terminal.s panic.s
	riscv32-unknown-elf-gcc  test1.c main.s test.s -Iinclude -o test.out -O0 -g3
	qemu-riscv32 -L /usr/riscv64-linux-gnu/ ./test.out