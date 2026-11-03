.section .rodata
mm: .ascii "my_first_process\n"
    .equ mm_len ,17
.section .text
.global first_proc

first_proc:
    addi s1, x0, 100
    print:
    li a0, mm_len
    la a1,mm
    li a2,0
    jal ra,write_string
    addi a0, s1, 0
    jal ra, printInt
    addi s1, s1, -1
    noprint:
    beq s1, x0, noprint
    jal zero,print #infinite loop
