QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -Iinclude
none:
	echo "In progress"
build: exception.S panic.s terminal.s trap_dispatch.s trap.s
	$(CC) $(CFLAGS) $^ -o core.o 