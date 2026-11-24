.include "struct.inc"
.global putChar
.global getChar
.global exit
.global getTicks
.global procInfo
.global yield
.global spawn
.global fileRead
.global fileWrite
.global putString
.section .text.start
.global start
start:
    la sp, __stack_top
    jal ra, main
    jal ra, exit

# terminates the process; the kernel frees its memory
exit:
    addi a3, x0, SYS_EXIT
    ecall
exit_hang:
    jal x0, exit_hang

# give up the rest of the time slice
yield:
    addi a3, x0, SYS_YIELD
    ecall
    jalr x0, 0(ra)

# a0 = program index (0 count_up, 1 count_down, 2 echo_storage) -> a0 = pid or -1
spawn:
    addi a3, x0, SYS_SPAWN
    ecall
    jalr x0, 0(ra)

# a0 = slot (1..16), a1 = 4096-byte buffer -> a0 = 0 on success
fileRead:
    addi a3, x0, SYS_FILE_READ
    ecall
    jalr x0, 0(ra)

fileWrite:
    addi a3, x0, SYS_FILE_WRITE
    ecall
    jalr x0, 0(ra)

# a0 = NUL-terminated string (printed by the kernel)
putString:
    addi a3, x0, SYS_PUTSTRING
    ecall
    jalr x0, 0(ra)
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
