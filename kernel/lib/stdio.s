.global     printInt
.global     printIntU
.global     printHex
.global     printHexDebug
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
        bge x0, t3, exit
        div t1, t0, t3 // Divide by 10 power
        rem t2, t0, t3 //remainder
        div t3, t3, t4
        addi t0, t2, 0
        addi a0, t1, 48 // Find ascii number
        jal     ra, write_byte
        jal x0, loop
exit:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)

printHex:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi t1, a0, 0
    addi t0, x0, 32

    addi a0, x0, 48
    jal ra, write_byte
    addi a0, a0, 120
    jal ra, write_byte
    
    loopHex:
        beq t0, x0, exit
        addi t0, t0, -4
        srl a0, t1, t0
        andi a0, a0, 0xf
        addi a0, a0, -10
        blt a0, x0, number
        addi a0, a0, 39
        number:
        addi a0, a0, 58
        jal ra, write_byte
        jal x0, loopHex
# Saves all registers
printHexDebug:
    addi sp, sp, -28
    sw ra, 0(sp)
    sw t1, 4(sp)
    sw t0, 8(sp)
    sw a7, 12(sp)
    sw a6, 16(sp)
    sw a0, 20(sp)
    sw a1, 24(sp)
    addi t1, a0, 0
    addi t0, x0, 32

    addi a0, x0, 48
    jal ra, write_byte
    addi a0, a0, 120
    jal ra, write_byte
    
    loopHexD:
        beq t0, x0, exitD
        addi t0, t0, -4
        srl a0, t1, t0
        andi a0, a0, 0xf
        addi a0, a0, -10
        blt a0, x0, numberD
        addi a0, a0, 39
        numberD:
        addi a0, a0, 58
        jal ra, write_byte
        jal x0, loopHexD
    exitD:
        lw ra, 0(sp)
        lw t1, 4(sp)
        lw t0, 8(sp)
        lw a7, 12(sp)
        lw a6, 16(sp)
        lw a0, 20(sp)
        lw a1, 24(sp)
        addi sp, sp, 28
        jalr x0, 0(ra)
