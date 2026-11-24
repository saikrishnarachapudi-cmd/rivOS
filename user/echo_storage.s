.include "struct.inc"

.section .rodata
prompt:  .asciz "Enter text to save to slot 2: "
saved:   .asciz "Saved to slot 2\n"
nl:      .asciz "\n"
bs_str:  .asciz "\b \b"
failed:  .asciz "Write failed (is disk.img present? run: make disk.img)\n"

.section .bss
buf:      .space 128
slotbuf:  .space 4096

.section .text
.global main

main:
    la   a0, prompt
    jal  ra, puts

    la   s0, buf
    li   s1, 0
read_loop:
    jal  ra, getChar
    li   t0, 13
    beq  a0, t0, enter
    li   t0, 10
    beq  a0, t0, enter
    li   t0, 127
    beq  a0, t0, backspace
    li   t0, 8
    beq  a0, t0, backspace
    li   t0, 32
    blt  a0, t0, read_loop
    li   t0, 126
    bgt  a0, t0, read_loop
    li   t0, 120
    bge  s1, t0, read_loop
    add  t1, s0, s1
    sb   a0, 0(t1)
    addi s1, s1, 1
    jal  ra, putChar
    j    read_loop
backspace:
    beqz s1, read_loop
    addi s1, s1, -1
    la   a0, bs_str
    jal  ra, puts
    j    read_loop
enter:
    add  t1, s0, s1
    sb   zero, 0(t1)
    la   a0, nl
    jal  ra, puts

    # prepare slotbuf: copy buf then zero rest (bss already zero, but ensure)
    la   t0, slotbuf
    la   t1, buf
    li   t2, 0
copy_loop:
    lbu  t3, 0(t1)
    sb   t3, 0(t0)
    beqz t3, copy_done
    addi t0, t0, 1
    addi t1, t1, 1
    addi t2, t2, 1
    li   t3, 127
    blt  t2, t3, copy_loop
copy_done:

    # write the whole slot through the kernel
    li   a0, 2
    la   a1, slotbuf
    jal  ra, fileWrite
    bnez a0, write_failed

    la   a0, saved
    jal  ra, puts
    jal  ra, exit
write_failed:
    la   a0, failed
    jal  ra, puts
    jal  ra, exit

# a0 = NUL-terminated string
puts:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s2, 4(sp)
    mv   s2, a0
puts_loop:
    lbu  a0, 0(s2)
    beqz a0, puts_done
    jal  ra, putChar
    addi s2, s2, 1
    j    puts_loop
puts_done:
    lw   ra, 0(sp)
    lw   s2, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)
