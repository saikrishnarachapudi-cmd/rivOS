CC      := clang
ROOT    ?= $(abspath ..)
CFLAGS  := -std=c11 -g3 -Wall -Wextra --target=riscv32-unknown-elf -nostdlib \
           -march=rv32imac_zicsr -I$(ROOT)/include $(EXTRA)

SRCS := boot.s main.s
build: $(SRCS)
	$(CC) -r $(CFLAGS) -fuse-ld=lld $^ -o boot.o

clean:
	rm -f boot.o
