.section .text
.global main

main:
    # every process currently runs the user shell binary,
    # so one process is enough for an interactive UI
    la a0, first_proc
    jal ra, proc_create
    #la a0, second_proc
    #jal ra, proc_create
    #la a0, third_proc
    #jal ra, proc_create
    jal ra, timer_init

sched_loop:
    jal  ra, scheduler
