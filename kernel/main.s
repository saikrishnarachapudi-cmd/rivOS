.section .text
.global main

main:
.ifdef DEMO
    # demo build (make demo): no shell - create 3 processes that each print 1..100
    la a0, _binary_proc1_bin_size
    la a1, _binary_proc1_bin_start
    la a2, _binary_proc1_bin_end
    jal ra, proc_create
    la a0, _binary_proc2_bin_size
    la a1, _binary_proc2_bin_start
    la a2, _binary_proc2_bin_end
    jal ra, proc_create
    la a0, _binary_proc3_bin_size
    la a1, _binary_proc3_bin_start
    la a2, _binary_proc3_bin_end
    jal ra, proc_create
.else
    # shell
    la a0, _binary_shell_bin_size
    la a1, _binary_shell_bin_start
    la a2, _binary_shell_bin_end
    jal ra, proc_create
.endif

    jal ra, timer_init

sched_loop:
    jal  ra, scheduler
