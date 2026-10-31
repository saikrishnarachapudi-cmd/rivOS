.include "struct.inc"
###returns the new process sp in a1.
#ra = proc_start 
#s0 = entry point
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
    li t5, proc_size          
    add t0, t0, t5
    addi t3, t3, 1
    addi t2, t2, -1
    jal x0, check

create:
    sw t3, proc_pid(t0)
    li t1, proc_ready
    sw t1, proc_state(t0)     

#stack top: proc_stacks + (pid + 1) * stack_size
    la t1, proc_stacks
    addi t4, t3, 1
    li t5, stack_size
    mul t4, t4, t5
    add t1, t1, t4        # t1 = top of stack

    #t4-stack size
    li t4, stack_size
    srli t4, t4, 2 
    mv t5, t1       

zero_frame:
    addi t5, t5, -4 
    sw zero, 0(t5) 
    addi t4, t4, -1  
    bnez t4, zero_frame

    #switch_context frame
    addi t1, t1, -52
    la t2, proc_start
    sw t2, 0(t1)      #ra = proc_start
    sw a0, 4(t1)      #s0 = entry point
    sw t1, proc_sp(t0)
      
    
    mv a0, t3 
    mv a1, t1 
    jalr zero, 0(ra)         

full:
    addi sp, sp, -8
    sw ra, 0(sp)
    li a0, len
    la a1, m
    jal ra, write_string
    li a0, -1
    lw ra, 0(sp)
    addi sp, sp, 8
    jalr zero, 0(ra)

proc_start:
    csrsi sstatus, 2
    jalr zero, (s0)

