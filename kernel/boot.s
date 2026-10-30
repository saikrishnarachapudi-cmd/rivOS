.include "struct.inc"
.global boot

    .section .rodata


.section .bss
    .align 4

    sec_code:
        .space 16    

    .global process_table
    process_table:
        .space proc_max * proc_size    

    .global proc_stacks
    proc_stacks:
        .space (proc_max+1) * stack_size

    .section .text.boot
boot:
    la sp, __stack_top

bss_zeroing:    
    la a0, __bss
    li a1, 0 
    la a2, __bss_end
    sub a2, a2, a0
    jal ra, memset0
bss_zero_end:
    la t0, enter_exception
    csrw stvec, t0
    jal ra, main ##main function
    jal x0, L1

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
