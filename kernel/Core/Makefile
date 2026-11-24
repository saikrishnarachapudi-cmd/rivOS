CC      := clang
ROOT    ?= $(abspath ..)
CFLAGS  := -std=c11 -g3 -Wall -Wextra --target=riscv32-unknown-elf -nostdlib \
           -march=rv32imac_zicsr -I$(ROOT)/include

SRCS := panic.s terminal.s trap_dispatch.s trap.s syscall.s
build: $(SRCS)
	$(CC) -r $(CFLAGS) -fuse-ld=lld $^ -o core.o

clean:
	rm -f core.o
