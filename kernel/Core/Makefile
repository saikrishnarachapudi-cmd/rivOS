QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude
build: assembleEach combine
assembleEach: exception.S panic.s terminal.s trap_dispatch.s trap.s
	$(CC) -c $(CFLAGS) $^
combine: exception.o panic.o terminal.o trap_dispatch.o trap.o
	$(CC) $(CFLAGS) -fuse-ld=lld -r $^ -o core.o