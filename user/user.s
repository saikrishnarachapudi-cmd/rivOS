.include "struct.inc"
.global start
.global putChar
.global getChar
.global getTicks
.global procInfo
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

# blocking read: returns the typed byte in a0
getChar:
    getChar_poll:
        addi a3, x0, SYS_GETCHAR
        ecall
        bltz a0, getChar_poll
    jalr x0, 0(ra)

# returns low 32 bits of the time counter in a0
getTicks:
    addi a3, x0, SYS_TICKS
    ecall
    jalr x0, 0(ra)

# a0 = process slot -> a0 = state (or -1)
procInfo:
    addi a3, x0, SYS_PROCINFO
    ecall
    jalr x0, 0(ra)

.global startDemo
startDemo:
    li a3, SYS_START_DEMO
    ecall
    ret
