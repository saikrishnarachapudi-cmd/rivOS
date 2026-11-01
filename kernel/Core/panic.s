#caller should send the message address in a0,
#file name address in a1,
##line number integer in  a2
.section .rodata
.word 15
m1: .ascii "Panic_message: "
.word 12
m2:  .ascii " File_name: "
.word 14
m3:.ascii " Line_number: "

.section .text
.global panic
panic:
    addi sp,sp,-16
    sw a0,0(sp)
    sw a1,4(sp)
    sw a2,8(sp)
    sw ra,12(sp)
    
    addi a0, x0, -1;
    la a1,m1
    jal ra, write_string
    
    addi a0, x0, -1;
    lw a1,0(sp)
    jal ra, write_string
    
    addi a0, x0, -1;
    la a1,m2
    jal ra, write_string
    
    addi a0, x0, -1;
    lw a1,4(sp)
    jal ra, write_string

    addi a0, x0, -1;
    la a1,m3
    jal ra, write_string
    
    lw a0,8(sp)
    jal ra, printInt
    lw ra, 12(sp)
    addi sp,sp,16
    jalr x0,0(ra)
