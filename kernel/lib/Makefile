CC      := clang
ROOT    ?= $(abspath ..)
CFLAGS  := -std=c11 -g3 -Wall -Wextra --target=riscv32-unknown-elf -nostdlib \
           -march=rv32imac_zicsr -I$(ROOT)/include

SRCS := mem_cpy.s memset0.s stdio.s ui.s
build: $(SRCS)
	$(CC) -r $(CFLAGS) -fuse-ld=lld $^ -o lib.o

clean:
	rm -f lib.o
