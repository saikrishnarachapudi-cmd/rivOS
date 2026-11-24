# Shared body for the three scheduler-demo processes.
# The including file must define a .rodata string labelled "tag" (e.g. "[P1] ")
# Prints "<tag>N" for N = 1..100, one whole line per putString syscall
# (the kernel handles a syscall with interrupts off, so lines never get
# mixed up between processes), with a short busy-wait between lines so the
# timer interrupt preempts the process and the scheduler interleaves them.

    .section .bss
line:   .space 32

    .section .text
    .global main

main:
    li   s0, 1                  # s0 = current number
next_num:
    # copy the tag into line[]
    la   s1, line
    la   t0, tag
copy_tag:
    lbu  t1, 0(t0)
    beqz t1, tag_done
    sb   t1, 0(s1)
    addi s1, s1, 1
    addi t0, t0, 1
    j    copy_tag
tag_done:
    # convert s0 to decimal into a small stack buffer, then append it
    addi sp, sp, -16
    addi t2, sp, 15
    mv   t3, s0
    li   t4, 10
digit_loop:
    remu t0, t3, t4
    divu t3, t3, t4
    addi t0, t0, 48
    addi t2, t2, -1
    sb   t0, 0(t2)
    bnez t3, digit_loop
    addi t5, sp, 15
append:
    bgeu t2, t5, append_done
    lbu  t0, 0(t2)
    sb   t0, 0(s1)
    addi s1, s1, 1
    addi t2, t2, 1
    j    append
append_done:
    addi sp, sp, 16
    li   t0, 10                 # '\n'
    sb   t0, 0(s1)
    sb   zero, 1(s1)
    la   a0, line
    jal  ra, putString

    # busy wait so the time slice runs out and the scheduler switches process
    li   t0, 30000
delay:
    addi t0, t0, -1
    bnez t0, delay

    addi s0, s0, 1
    li   t0, 100
    ble  s0, t0, next_num
    jal  ra, exit
