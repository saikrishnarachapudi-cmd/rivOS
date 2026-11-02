.section .rodata
mm: .ascii "my_first_process\n"
    .equ mm_len ,17
.section .text
.global first_proc

first_proc:
    addi t0, x0, 10;
    jal ra, counter
    print:
    li a0, mm_len
    la a1,mm
    li a2,0
    jal ra,write_string
    addi t0, t0, -1
    noprint:
    beq t0, x0, noprint
    jal zero,print #infinite loop

counter:
    addi t1, x0, 1
    slli t1, t1, 20
    loop:
        addi t1, t1, -1
        blt t1, x0, exit
        jal x0, loop
    exit:
    jalr x0, 0(ra)