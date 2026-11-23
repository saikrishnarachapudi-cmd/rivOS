.include "struct.inc"
.global test
.global setup
.global getFileContent
.global saveFileContent
.global closeFile
.data
letter:.ascii "C"
fileName: .asciz "disk.img"
content: .asciz "Hello World"
argArr: .word 0, 0, 0
writeArgArr: .word 0, 0, 0
readArgArr: .word 0, 0, 0
seekArgArr: .word 0, 0
closeArgArr: .word 0
.text
.option push
.option norvc
# opens disk.img in read/write binary mode and stores the handle
# in writeArgArr / readArgArr / seekArgArr
setup:
    la a1, argArr
    la t0, fileName
    sw t0, 0(a1)

    addi t0, x0, 3          # mode 3 = r+b (read/write binary)
    sw t0, 4(a1)

    addi t0, x0, 8          # filename length
    sw t0, 8(a1)

    addi a0, x0, SYS_OPEN
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7          # a0 = file handle

    la t0, writeArgArr
    sw a0, 0(t0)
    la t0, readArgArr
    sw a0, 0(t0)
    la t0, seekArgArr
    sw a0, 0(t0)
    la t0, closeArgArr
    sw a0, 0(t0)
    jalr x0, 0(ra)
.option pop

.option push
.option norvc
# reads one 4096-byte file slot into the buffer given in a0
# a0 - destination buffer address
# a1 - file number (1-based)
getFileContent:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    addi s0, a0, 0# s0 = destination buffer

    # seek to (fileNum-1) * 4096
    la t0, seekArgArr
    addi t1, a1, -1
    lui t2, 1               # 4096
    mul t1, t1, t2
    sw t1, 4(t0)
    la a1, seekArgArr
    addi a0, x0, SYS_SEEK
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7

    # read 4096 bytes into s0
    la t0, readArgArr
    la t1, seekArgArr
    lw t2, 0(t1)            # handle
    sw t2, 0(t0)
    sw s0, 4(t0)            # buffer
    lui t2, 1               # 4096
    sw t2, 8(t0)            # length
    la a1, readArgArr
    addi a0, x0, SYS_READ
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)
.option pop

.option push
.option norvc
# writes one 4096-byte file slot from the buffer given in a0
# a0 - source buffer address
# a1 - file number (1-based)
saveFileContent:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    addi s0, a0, 0# s0 = source buffer

    # seek to (fileNum-1) * 4096
    la t0, seekArgArr
    addi t1, a1, -1
    lui t2, 1               # 4096
    mul t1, t1, t2
    sw t1, 4(t0)
    la a1, seekArgArr
    addi a0, x0, SYS_SEEK
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7

    # write 4096 bytes from s0
    la t0, writeArgArr
    la t1, seekArgArr
    lw t2, 0(t1)            # handle
    sw t2, 0(t0)
    sw s0, 4(t0)            # buffer
    lui t2, 1               # 4096
    sw t2, 8(t0)            # length
    la a1, writeArgArr
    addi a0, x0, SYS_WRITE
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7

    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)
.option pop

.option push
.option norvc
# closes the open disk.img handle
closeFile:
    la t0, closeArgArr
    la a1, closeArgArr
    addi a0, x0, SYS_CLOSE
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7
    jalr x0, 0(ra)
.option pop
