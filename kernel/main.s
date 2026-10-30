.section .text
.global main
.text
main:
    unimp
    jal x0, L1
L1:
    wfi
    jal  x0, L1

    
sched_loop:
    jal  ra, scheduler 
    j  sched_loop
    