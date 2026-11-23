.section .text
.global main

main:
    # shell
    la a0, _binary_shell_bin_size
    la a1, _binary_shell_bin_start
    la a2, _binary_shell_bin_end
    jal ra, proc_create

    jal ra, timer_init

sched_loop:
    jal  ra, scheduler
