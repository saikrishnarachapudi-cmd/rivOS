.section .text
.global main

main:
    addi sp, sp, -16
    sw ra, 0(sp)

    la   a0, first_proc
    jal  ra, proc_create 

    la   a0, second_proc
    jal  ra, proc_create

    
sched_loop:
    jal  ra, scheduler 
    j  sched_loop
    
    