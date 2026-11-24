CC      := clang
ROOT    ?= $(abspath ..)
CFLAGS  := -std=c11 -O2 -g3 -Wall -Wextra --target=riscv32-unknown-elf -fuse-ld=lld \
           -fno-stack-protector -ffreestanding -nostdlib \
           -march=rv32imac_zicsr -I$(ROOT)/include
OBJCOPY := llvm-objcopy

APPS    := shell count_up count_down echo_storage proc1 proc2 proc3

build:
	for app in $(APPS); do \
		$(CC) $(CFLAGS) -Tuser.ld $$app.s user.s -o $$app.elf || exit 1; \
		$(OBJCOPY) --set-section-flags .bss=alloc,contents -O binary $$app.elf $$app.bin; \
		$(OBJCOPY) -Ibinary -Oelf32-littleriscv $$app.bin $$app.bin.o; \
	done

clean:
	rm -f *.elf *.bin *.bin.o
