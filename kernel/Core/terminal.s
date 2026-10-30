# call to OpenSBI Legacy version(Only used to write and read to console in this project)
# may be update in future
# a0 - a5 arguments
# a7 - EID - Extension ID
# a6 - FID - function ID - not needed
    .global write_byte
    .global read_byte
    .global remove_byte
    .global write_string
    .global read_string
# letter in a0
write_byte:
    li      a7, 0x4442434E
    li      a6,     2
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

# number of bytes in a0
##if a0 is negative, then the number just before the string is taken to be the length
# base address low in a1
# base address high in a2
write_string:
    li  a7, 0x4442434E
    bge a0, x0, len_in_reg
    lw a0, -4(a1)
    len_in_reg:
        li  a6,     0
        li a2,  0
        ecall
        jalr    zero, 0(ra)

# maximum number of bytes to read in a0
# base address low in a1
# base address high in a2
# a0(error status)=0 if successfull reading
# a1 number of bits read
read_string:
    li  a7, 0x4442434E
    li  a6, 1
    li a2,0
    ecall
    jalr zero, 0(ra)