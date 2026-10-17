CC=clang  
CFLAGS=-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32-unknown-elf -fno-stack-protector -ffreestanding -nostdlib -march=rv32imac_zicsr
stdlib.o: terminal.S
	$(CC) $(CFLAGS) -c terminal.S -o stdlib.o