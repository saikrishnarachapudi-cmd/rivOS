.section .text
    .global memset0

#a0-dest address
#a1-byte value
#a2-no.of bytes

memset0:
    addi t0,a0,0

loop:
    beq a2,zero,exit
    sb zero,0(t0)
    addi t0,t0,1
    addi a2,a2,-1
    beq zero,zero,loop

exit:
    jalr zero, 0(ra)
