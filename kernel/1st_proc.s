.section .rodata
mm: .ascii "my_first_process"
    .equ mm_len ,16
.section .text
.global first_proc

first_proc:
    li a0, mm_len
    la a1,mm
    li a2,0
    jal ra,write_string

    jal zero,first_proc #infinite loop
