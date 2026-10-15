# call to OpenSBI Legacy version(Only used to write and read to console in this project)
# may be update in future
# a0 - a5 arguments
# a7 - EID - Extension ID
# a6 - FID - function ID - not needed
.global write_byte
.global read_byte
write_byte:
    addi    a7, zero, 1
    add x0, x0, x0
    ecall
    jalr    zero, 0(ra)

read_byte:
    addi    a7, zero, 2
    addi    t1, zero, -1
    repeat_read:
        ecall
        beq     a0, t1, repeat_read
    ecall
    jalr    zero, 0(ra)

# sbi_call:
# ecall
# jalr x0, 0(ra)