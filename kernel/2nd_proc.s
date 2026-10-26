.section .rodata
mm2: .ascii "my_second_process"
    .equ mm2_len ,17
.section .text
.global second_proc

second_proc:
    li a0, mm2_len
    la a1,mm2
    li a2,0
    jal ra,write_string

    jal zero,second_proc #infinite loop
