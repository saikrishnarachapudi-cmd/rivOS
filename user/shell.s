    .section .rodata
mm: .ascii "my_first_process\n"
    .equ mm_len ,17
.section .text
.global main

main:
    addi s1, x0, 100
    li t0, mm_len
    la a1,mm
    printloop:
        beq t0, x0, loop
        lw a0, 0(a1)
        addi a1, a1, 1
        jal ra, putChar
        jal x0, printloop
    loop:
    jal x0, loop
