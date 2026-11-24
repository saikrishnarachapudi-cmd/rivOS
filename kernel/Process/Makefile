CC      := clang
ROOT    ?= $(abspath ..)
CFLAGS  := -std=c11 -g3 -Wall -Wextra --target=riscv32-unknown-elf -nostdlib \
           -march=rv32imac_zicsr -I$(ROOT)/include

SRCS := proc_create.s sbi_timer.s scheduler.s switch_context.s
build: $(SRCS)
	$(CC) -r $(CFLAGS) -fuse-ld=lld $^ -o process.o

clean:
	rm -f process.o
