.section .rodata
mm3: .ascii "my_third_process"
    .equ mm3_len ,16
.section .text
.global third_proc

third_proc:
    li a0, mm3_len
    la a1,mm3
    li a2,0
    jal ra,write_string

    jal zero,third_proc #infinite loop
