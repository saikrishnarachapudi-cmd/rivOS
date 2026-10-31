.section .text
.global main

main:
    
    la a0, first_proc
    jal ra, create_proc
    la a0, second_proc
    jal ra, create_proc
    jal ra, timer_init
    
    
    
sched_loop:
    jal  ra, scheduler 
    j  sched_loop
    