.include "struct.inc"
.global putChar
.section .text.start
start:
    la sp, __stack_top
    jal ra, main
    jal ra, exit

exit:
    jal x0, exit
# letter in a0
putChar:
    addi a3, x0, SYS_PUTCHAR
    ecall
    jalr x0, 0(ra)
