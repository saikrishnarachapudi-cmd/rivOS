.global boot

    .section .rodata
message:
    .ascii "Hello world"
msg_len = . - message

    .section .bss
    .align 2
sec_code:
    .space 16               

    .section .text
boot:
    addi a0, zero, 67
    jal  ra, write_byte
    addi a0, zero, 67
    jal  ra, write_byte
    addi a0, zero, 67
    jal  ra, write_byte
    jal  ra, remove_byte
    addi a0, zero, 32
    jal  ra, write_byte

    li a0, msg_len   
    la   a1, message       
    jal  ra, write_string

input:
   
    addi a0, zero, 16        
    la   a1, sec_code         
    jal  ra, read_string

    
    bnez a0, input       
    beqz a1, input       

   
    mv   a0, a1              
    la   a1, sec_code         
    jal  ra, write_string

L1:
    wfi
    jal  x0, L1
