.section .text
    .global memcpy

#copying n bytes form a1 to a0

# a0 = dst address
# a1 = src address
# a2 = n bytes

memcpy:
    addi t0, a0, 0

loop:
    beq a2, zero, exit
    
    lbu t1, 0(a1)
    sb t1, 0(t0)
    addi t0, t0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    jal zero, loop

exit:
    jalr    zero, 0(ra)