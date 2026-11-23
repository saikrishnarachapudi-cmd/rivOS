.include "struct.inc"

.section .rodata
prompt:  .asciz "Enter text to save to slot 2: "
saved:   .asciz "Saved to slot 2\n"
nl:      .asciz "\n"
bs_str:  .asciz "\b \b"
fileName:.asciz "disk.img"

.section .bss
buf:      .space 128
slotbuf:  .space 4096
argArr:   .space 12
writeArgArr: .space 12
seekArgArr:  .space 8
closeArgArr: .space 4

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

    # open disk.img (mode 3 = r+b)
    la   a1, argArr
    la   t0, fileName
    sw   t0, 0(a1)
    li   t0, 3
    sw   t0, 4(a1)
    li   t0, 8
    sw   t0, 8(a1)
    li   a0, SYS_OPEN
    jal  ra, semihost
    # a0 = handle
    la   t0, writeArgArr
    sw   a0, 0(t0)
    la   t0, seekArgArr
    sw   a0, 0(t0)
    la   t0, closeArgArr
    sw   a0, 0(t0)

    # seek to slot 2 offset = 4096
    la   t0, seekArgArr
    li   t1, 4096
    sw   t1, 4(t0)
    la   a1, seekArgArr
    li   a0, SYS_SEEK
    jal  ra, semihost

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

    # write 4096 bytes
    la   t0, writeArgArr
    la   t1, seekArgArr
    lw   t2, 0(t1)
    sw   t2, 0(t0)          # handle
    la   t2, slotbuf
    sw   t2, 4(t0)          # buffer
    li   t2, 4096
    sw   t2, 8(t0)          # length
    la   a1, writeArgArr
    li   a0, SYS_WRITE
    jal  ra, semihost

    # close
    la   a1, closeArgArr
    li   a0, SYS_CLOSE
    jal  ra, semihost

    la   a0, saved
    jal  ra, puts
    jal  ra, exit

# semihosting trap
semihost:
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7
    jalr x0, 0(ra)

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
