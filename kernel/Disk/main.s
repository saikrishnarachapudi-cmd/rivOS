.global test
.data
letter:.ascii "C"
fileName: .asciz "disk.img"
content: .asciz "Hello World"
argArr: .word 0, 0, 0
writeArgArr: .word 0, 0, 0
readArgArr: .word 0, 0, 0
seekArgArr: .word 0, 0
#handle: .word 0
.text
.option push
.option norvc
setup:
    la a1, argArr
    la t0, fileName
    sw t0, 0(a1)

    addi t0, x0, 3
    sw t0, 4(a1)

    addi t0, x0, 8
    sw t0, 8(a1)


    addi a0, x0, 1
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7
    la t0, writeArgArr # saving the handles
    sw a0, 0(t0)
    la t0, readArgArr # saving the handles
    sw a0, 0(t0)
    la t0, seekArgArr # saving the handles
    sw a0, 0(t0)
    
    # la t1, content
    # sw t1, 4(t0)

    # addi t1, x0, 11
    # sw t1, 8(t0)

    # addi a0, x0, 5
    # la a1, writeArgArr
    # slli x0, x0, 0x1f
    # ebreak
    # srai x0, x0, 7

    jalr x0, 0(ra)
.option pop

.option push
.option norvc
# all files are 4096 bytes
# max 128 files
# gets the file content
# a0 - start address to store
# a1 - file number
getFileContent:
    la t0, seekArgArr
    addi a1, a1, -1
    lui t3, 1 # size of each file
    mul a1, a1,  t3
    sw a1, 4(t0) # a1 to set the seek to start of file
    addi a0, x0, 0x0A # set the seek
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7

    addi a0, x0, 0x06 # read the data
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7



.option pop