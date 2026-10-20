.section .text
    .global memset0

#a0-dest address
#a1-char ascii value
#a2-no.of bytes

memset0:
    addi t0,a0,0

loop:
    beq a2,zero,exit
    sd zero,0(t0)
    addi t0,t0,1
    beq zero,zero,loop

exit:
    jal zero, 0(ra)
