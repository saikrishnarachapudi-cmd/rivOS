    .global boot
    .data
    .text
boot:
    addi    a0, zero, 67
    jal     ra, read_byte
L1:
    wfi
    jal     x0, L1

