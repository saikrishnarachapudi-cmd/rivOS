.section .rodata
mm2: .ascii "my_second_process\n"
    .equ mm2_len ,18
.section .text
.global second_proc

second_proc:
    addi t0, x0, 10;
    print:
    li a0, mm2_len
    la a1,mm2
    li a2,0
    jal ra,write_string
    addi t0, t0, -1
    noprint:
    beq t0, x0, noprint
    jal zero,print #infinite loop
