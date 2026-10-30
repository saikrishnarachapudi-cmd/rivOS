.global     printInt
.global     printIntU
.text
printIntU:
    addi sp, sp, -4
    sw ra, 0(sp)// Saving return address as it is changed
    addi t0, a0, 0
    addi t3, x0, 1
    addi t4, x0, 10 //always 10
    beq x0, x0, power // bypass negative check
printInt:
    addi sp, sp, -4
    sw ra, 0(sp)// Saving return address as it is changed
    addi t0, a0, 0
    addi t3, x0, 1
    addi t4, x0, 10 //always 10
    bge t0, x0, power // continue if positive
    sub t0, x0, t0
    addi a0, x0, 45
    jal     ra, write_byte

    power:
        mul t3, t3, t4
        bge t0, t3, power
    div t3, t3, t4
    # addi a0, x0, 69 // Find ascii number
    # jal     ra, write_byte
    loop:
        bge x0, t3, exitprintInt
        div t1, t0, t3 // Divide by 10 power
        rem t2, t0, t3 //remainder
        div t3, t3, t4
        addi t0, t2, 0
        addi a0, t1, 48 // Find ascii number
        jal     ra, write_byte
        jal x0, loop
    exitprintInt:
        lw ra, 0(sp)
        addi sp, sp, 4
        jalr x0, 0(ra)
