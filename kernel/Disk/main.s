.include "struct.inc"
# Disk driver: the disk is the host file "disk.img" accessed through QEMU
# semihosting (launch QEMU with -semihosting-config enable=on,...).
# The disk is DISK_SLOTS slots of DISK_SLOT_SIZE (4096) bytes; slot numbers are 1-based.
.global disk_init
.global getFileContent
.global saveFileContent
.global closeFile
.global disk_ready

.section .rodata
fileName: .asciz "disk.img"
msg_nodisk: .asciz "  \033[1;33m[WARN]\033[0m disk.img not found - file syscalls disabled (run: make disk.img)\n"
msg_disk:   .asciz "  \033[1;32m[ OK ]\033[0m disk.img opened (16 x 4096-byte slots)\n"

.data
disk_ready:  .word 0
disk_handle: .word -1
argArr:      .word 0, 0, 0       # open : name, mode, name length
rwArgArr:    .word 0, 0, 0       # read/write : handle, buffer, length
seekArgArr:  .word 0, 0          # seek : handle, absolute position
closeArgArr: .word 0             # close : handle

.text
# semihosting call: a0 = operation, a1 = argument block -> a0 = result
.option push
.option norvc
semihost:
    slli x0, x0, 0x1f
    ebreak
    srai x0, x0, 7
    jalr x0, 0(ra)
.option pop

# opens disk.img (mode 3 = r+b). Sets disk_ready = 1 on success.
disk_init:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a1, argArr
    la t0, fileName
    sw t0, 0(a1)
    li t0, 3
    sw t0, 4(a1)
    li t0, 8
    sw t0, 8(a1)
    li a0, SH_OPEN
    jal ra, semihost
    bltz a0, disk_fail
    la t0, disk_handle
    sw a0, 0(t0)
    la t0, disk_ready
    li t1, 1
    sw t1, 0(t0)
    la a0, msg_disk
    jal ra, kputs
    j disk_init_end
disk_fail:
    la a0, msg_nodisk
    jal ra, kputs
disk_init_end:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)

# common worker: seeks to (slot-1)*4096 then reads or writes one slot
# a0 = buffer, a1 = slot (1-based), a2 = SH_READ or SH_WRITE
# returns a0 = 0 on success, non-zero on error
disk_rw:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a2
    la t0, disk_ready
    lw t0, 0(t0)
    beqz t0, disk_rw_bad
    beqz a1, disk_rw_bad
    li t0, DISK_SLOTS
    bgtu a1, t0, disk_rw_bad

    la t0, disk_handle
    lw t0, 0(t0)
    la t2, seekArgArr
    sw t0, 0(t2)
    addi t1, a1, -1
    slli t1, t1, 12                 # * 4096
    sw t1, 4(t2)
    la a1, seekArgArr
    li a0, SH_SEEK
    jal ra, semihost
    bnez a0, disk_rw_bad

    la t0, disk_handle
    lw t0, 0(t0)
    la t2, rwArgArr
    sw t0, 0(t2)
    sw s0, 4(t2)
    li t1, DISK_SLOT_SIZE
    sw t1, 8(t2)
    la a1, rwArgArr
    mv a0, s1
    jal ra, semihost                # a0 = bytes NOT transferred (0 = success)
    j disk_rw_end
disk_rw_bad:
    li a0, -1
disk_rw_end:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jalr x0, 0(ra)

# a0 - destination buffer, a1 - file number (1-based)
getFileContent:
    li a2, SH_READ
    j disk_rw

# a0 - source buffer, a1 - file number (1-based)
saveFileContent:
    li a2, SH_WRITE
    j disk_rw

# closes the disk handle
closeFile:
    addi sp, sp, -4
    sw ra, 0(sp)
    la t0, disk_ready
    lw t1, 0(t0)
    beqz t1, close_end
    sw zero, 0(t0)
    la t0, disk_handle
    lw t0, 0(t0)
    la a1, closeArgArr
    sw t0, 0(a1)
    li a0, SH_CLOSE
    jal ra, semihost
close_end:
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
