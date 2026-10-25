#caller should send the message address in a0,file name address in a1,line no address a2
.section .rodata
m1: .ascii "panic_message: "

m2:  .ascii "file_name: "

m3:.ascii "line_number: "

.section .text
.global panic
panic:
    addi sp,sp,-12
    sw a0,0(sp)
    sw a1,4(sp)
    sw a2,8(sp)
    la a0,m1
    jal ra, write_string
    lw a0,0(sp)
    jal ra, write_string
    la a0,m2
    jal ra, write_string
    lw a0,4(sp)
    jal ra, write_string
    la a0,m3
    jal ra, write_string
    lw a0,8(sp)
    jal ra, write_string
    addi sp,sp,12
    jal zero,0(ra)
