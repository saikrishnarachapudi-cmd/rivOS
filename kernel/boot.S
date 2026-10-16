    .global boot
    .data
    .text
boot:
    addi    a0, zero, 67
    jal     ra, write_byte
    addi    a0, zero, 67
    jal     ra, write_byte
    addi    a0, zero, 67
    jal     ra, write_byte
    jal     ra, remove_byte
L1:
    wfi
    jal     x0, L1

