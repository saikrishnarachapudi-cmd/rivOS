.include "struct.inc"
###returns the new process sp in a1.
.section .rodata
    m:
    .ascii "out of space for another process"
    .equ len, 32

.section .text 
    .global proc_create

#pid = 0,1,2...max-1
# returns a0 = pid  or -1 if the process table is full
proc_create:
    la t0, process_table        
    li t2, proc_max    
    li t3, 0  #t3=pid of new process          

check:
    beq t2,zero,full
    lw t1, proc_state(t0)
    beq t1,zero, create               
    addi t0, t0, proc_size
    addi t3, t3, 1
    addi t2, t2, -1
    jal x0, check

create:
    sw t3, proc_pid(t0)
    li t1, proc_ready
    sw t1, proc_state(t0)     

    # stack top = proc_stacks + (pid + 1) * stack_size
    la t1, proc_stacks
    addi t4, t3, 1
    li t5, stack_size
    mul t4, t4, t5
    add t1, t1, t4
    sw t1, proc_sp(t0)
    mv a1, t1
    
full:
    addi sp, sp, -8
    sw ra, 0(sp)
    li a0, len
    la a1, m
    jal a, write_string
    li a0, -1
    lw ra, 0(sp)
    addi sp, sp, 8
    jalr zero, 0(ra)
