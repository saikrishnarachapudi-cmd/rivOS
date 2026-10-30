QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf  -nostdlib \
           -march=rv32imac_zicsr -Iinclude\
           #-O2 -fno-stack-protector -ffreestanding
build: assembleEach combine
assembleEach: exception.s panic.s terminal.s trap_dispatch.s trap.s
	$(CC) -c $(CFLAGS) $^
combine: exception.o panic.o terminal.o trap_dispatch.o trap.o
	$(CC) $(CFLAGS) -fuse-ld=lld -r $^ -o core.o