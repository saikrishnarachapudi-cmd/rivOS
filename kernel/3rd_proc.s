.section .rodata
mm3: .ascii "my_third_process\n"
    .equ mm3_len ,17
.section .text
.global third_proc

third_proc:
    addi t0, x0, 10
    print:
    li a0, mm3_len
    la a1,mm3
    li a2,0
    jal ra,write_string
    addi t0, t0, -1
    noprint:
    beq t0, x0, noprint
    jal zero,print #infinite loop
