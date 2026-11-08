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

    #trap vector(when a trap occurs , opensbi will trasfer control to the address present in stvec)
    la t0, trap_entry
    csrw stvec, t0
    
bss_zeroing:
    addi a0, x0, 10
    //jal ra, write_byte
    la a0, _binary_shell_bin_start
    //jal ra, printHex
    addi a0, x0, 10
    //jal ra, write_byte
    la a0, _binary_shell_bin_end
    //jal ra, printHex
    addi a0, x0, 10
    //jal ra, write_byte
    la a0, __bss
    li a1, 0 
    la a2, __bss_end
    sub a2, a2, a0
    jal ra, memset0
bss_zero_end:
    jal ra, printMem
    jal ra, main ##main function




