.include "struct.inc"
.global boot

    .section .rodata
message:
    .ascii "Hello world"
msg_len = . - message


.section .bss
    .align 4

    sec_code:
        .space 16    

    .global process_table
    process_table:
        .space proc_max * proc_size    

    .global proc_stacks
    proc_stacks:
        .space proc_max * stack_size

    .section .text
boot:

    addi a0, zero, 67
    jal  ra, write_byte
    addi a0, zero, 67
    jal  ra, write_byte
    addi a0, zero, 67
    jal  ra, write_byte
    jal  ra, remove_byte
    addi a0, zero, 32
    jal  ra, write_byte

    li a0, msg_len   
    la   a1, message       
    jal  ra, write_string

process_creation:
    jal ra, proc_create
    ##incomplete


input:
    li   a0, 16
    la   a1, sec_code
    jal  ra, read_string

    # a0 = SBI error status
    # a1 = number of bytes read

    bnez a0, input       # Retry if error
    beqz a1, input       # Retry if no bytes read

    # Print the input buffer
    mv   t0, a1          # Save number of bytes read
    mv   a0, t0          # Length for write_string
    la   a1, sec_code    # Address of input buffer
    jal  ra, write_string
    # optional: newline
    addi a0, zero, 10
    jal  ra, write_byte

    
L1:
    wfi
    jal  x0, L1
