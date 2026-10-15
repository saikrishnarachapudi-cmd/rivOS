# call to OpenSBI Legacy version(Only used to write and read to console in this project)
# may be update in future
# a0 - a5 arguments
# a7 - EID - Extension ID
# a6 - FID - function ID - not needed
    .global write_byte
    .global read_byte
    .global remove_byte
# letter in
write_byte:
    addi    a7, zero, 1
    ecall
    jalr    zero, 0(ra)

read_byte:
    addi    a7, zero, 2
    addi    t1, zero, -1
    repeat_read:
        ecall
        beq     a0, t1, repeat_read
    addi    a7, zero, 1
    ecall
    jalr    zero, 0(ra)
remove_byte:
    addi    a7, zero, 1
    addi    a0, zero, 8 // backspace - go one letter left
    ecall
    addi    a0, zero, 32 // space - to clear it
    ecall
    addi    a0, zero, 8 // go back again
    ecall
    jalr    zero, 0(ra)

# sbi_call:
# ecall
# jalr x0, 0(ra)