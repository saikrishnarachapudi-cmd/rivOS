.section .rodata
mm2: .ascii "my_second_process\n"
    .equ mm2_len ,18
.section .text
.global second_proc

second_proc:
    addi s1, x0, 100
    print:
    li a0, mm2_len
    la a1,mm2
    li a2,0
    jal ra,write_string
    addi a0, s0, 0
    jal ra, printInt
    addi s1, s1, -1
    noprint:
    beq s1, x0, noprint
    jal zero,print #infinite loop
