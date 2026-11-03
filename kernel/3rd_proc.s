.section .rodata
mm3: .ascii "my_third_process\n"
    .equ mm3_len ,17
.section .text
.global third_proc

third_proc:
    addi s1, x0, 100
    print:
    li a0, mm3_len
    la a1,mm3
    li a2,0
    jal ra,write_string
    addi a0, s1, 0
    jal ra, printInt
    addi s1, s1, -1
    noprint:
    beq s1, x0, noprint
    jal zero,print #infinite loop

