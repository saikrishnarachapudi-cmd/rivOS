QEMU    := qemu-system-riscv32
CC      := clang
CFLAGS  := -std=c11 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -nostdlib \
           -march=rv32imac_zicsr -Iinclude
            #-O2  -fno-stack-protector -ffreestanding 
build: assembleEach combine
assembleEach: proc_create.s sbi_timer.s scheduler.s switch_context.s
	$(CC) -c $(CFLAGS) $^
combine: proc_create.o sbi_timer.o scheduler.o switch_context.o
	$(CC) $(CFLAGS)  -fuse-ld=lld -r $^ -o process.o