.section .text
.global main

# Boot only the shell. Command "1" will start the three demo tasks.
main:
    jal ra, proc_create_shell
    jal ra, timer_init
scheduler_forever:
    jal ra, scheduler
    j scheduler_forever
