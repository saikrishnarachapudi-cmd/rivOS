.include "struct.inc"

.section .rodata
nl: .asciz "\n"

.section .text
.global main

main:
    li   s0, 1
loop:
    mv   a0, s0
    jal  ra, print_uint
    la   a0, nl
    jal  ra, puts
    addi s0, s0, 1
    li   t0, 100
    ble  s0, t0, loop
    jal  ra, exit

# a0 = NUL-terminated string
puts:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s2, 4(sp)
    mv   s2, a0
puts_loop:
    lbu  a0, 0(s2)
    beqz a0, puts_done
    jal  ra, putChar
    addi s2, s2, 1
    j    puts_loop
puts_done:
    lw   ra, 0(sp)
    lw   s2, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)

# a0 = unsigned number
print_uint:
    addi sp, sp, -32
    sw   ra, 28(sp)
    addi t2, sp, 24
    sb   zero, 0(t2)
    li   t3, 10
pu_loop:
    remu t0, a0, t3
    divu a0, a0, t3
    addi t0, t0, 48
    addi t2, t2, -1
    sb   t0, 0(t2)
    bnez a0, pu_loop
    mv   a0, t2
    jal  ra, puts
    lw   ra, 28(sp)
    addi sp, sp, 32
    jalr x0, 0(ra)
