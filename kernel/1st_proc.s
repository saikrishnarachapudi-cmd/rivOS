.section .rodata
mm: .ascii "my_first_process"
    .equ mm_len ,16
.section .text
.global first_proc

first_proc:
    addi t0, x0, 10;
    print:
    li a0, mm_len
    la a1,mm
    li a2,0
    jal ra,write_string
    addi t0, t0, -1
    noprint:
    beq t0, x0, noprint
    jal zero,print #infinite loop
