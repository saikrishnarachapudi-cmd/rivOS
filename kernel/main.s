.section .text
.global main

main:
    
    la a0, first_proc
    jal ra, proc_create
    la a0, second_proc
    jal ra, proc_create
    jal ra, timer_init

    
    
sched_loop:
    jal  ra, scheduler 
    j  sched_loop
    