    .global kernel_main
    .data
    message: .ascii "Hello world"
    .text
kernel_main:
    addi    a0, zero, 67
    jal     ra, write_byte
    addi    a0, zero, 67
    jal     ra, write_byte
    addi    a0, zero, 67
    jal     ra, write_byte
    jal     ra, remove_byte
    addi    a0, zero, 32
    jal     ra, write_byte
    la      a1, message
    addi    a0, zero, 11
    jal     ra, write_string
L1:
    wfi
    jal     x0, L1

