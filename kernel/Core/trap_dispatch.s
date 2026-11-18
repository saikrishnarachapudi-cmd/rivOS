.include "struct.inc"
.section .rodata
.word 3
ILLEGAL_INST: .ascii ":An Illegal ins"
.word 3
FILE_NAME: .ascii "trap_dispatch.s"
.word 34
m7: .ascii "This exception is not considered\n"

.section .text
.global trap_dispatch

#scause: Why did the trap happen?
#sepc: At which instruction did it happen?
#stval: What additional trap-specific information is available?
#sstatus: What was the CPU's privilege and interrupt state?
#sie / sip: Which supervisor interrupts are enabled or pending?

trap_dispatch:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    mv   s0, a0

    csrr t0,sepc
    csrr t1,sstatus
    csrr t2,scause
    csrr t3,stval
    csrr t4, sie

    li a1,8
    beq t2,a1,env_u
    li a0,1
    slli a0,a0,31
    addi a0,a0,5
    beq a0,t2,timer
    li a0,2
    beq t2,a0,illegal_inst
    loop:
        wfi
        jal x0, loop
timer:
    jal ra, sbi_timer
    jal ra, sched_switch
label:
    jal ra, done
    
illegal_inst:
    # lw t0, 124(s0)
    # addi t0, t0, 4
    # sw t0, 124(s0)
    # j done
    # la a0, ILLEGAL_INST
    # la a1, FILE_NAME
    # addi a2, x0, 55
    # jal ra, panic
    addi a0, x0, 67
    jal ra, write_byte
    loop2: 
        wfi
        jal x0, loop2
env_u:
    # syscall from usermode here
    # number in a3, argument in a0 (saved in trap frame)
    lw a3, (48)(s0)
    lw a0, (36)(s0)

    addi sp, sp, -4
    sw ra, 0(sp)

    addi t0, x0, SYS_PUTCHAR
    beq a3, t0, putChar
    addi t0, x0, SYS_GETCHAR
    beq a3, t0, getChar
    addi t0, x0, SYS_SHUTDOWN
    beq a3, t0, shutdown
    addi t0, x0, SYS_TICKS
    beq a3, t0, ticks
    addi t0, x0, SYS_PROCINFO
    beq a3, t0, procinfo
    jal x0, sysCallEnd          # unknown syscall: ignore

    # returns the low 32 bits of the time counter (10 MHz on QEMU virt)
    ticks:
        rdtime t0
        sw t0, (36)(s0)
        jal x0, sysCallEnd

    # a0 = process slot index -> returns its state (0 unused,1 ready,2 running,3 blocked)
    # or -1 if the index is out of range
    procinfo:
        li t0, proc_max
        bgeu a0, t0, procinfo_bad
        li t0, proc_size
        mul t0, t0, a0
        la t1, process_table
        add t1, t1, t0
        lw t0, proc_state(t1)
        sw t0, (36)(s0)
        jal x0, sysCallEnd
    procinfo_bad:
        li t0, -1
        sw t0, (36)(s0)
        jal x0, sysCallEnd

    putChar:
        jal ra, write_byte
        jal x0, sysCallEnd

    # non-blocking: returns the byte in a0, or -1 if no input is pending.
    # result goes into the saved a0 of the trap frame
    getChar:
        addi a7, x0, 2          # SBI legacy console_getchar
        ecall
        sw a0, (36)(s0)
        jal x0, sysCallEnd

    # SBI SRST: system reset (shutdown)
    shutdown:
        li a7, 0x53525354
        li a6, 0
        li a0, 0
        li a1, 0
        ecall
        jal x0, shutdown

    sysCallEnd:
    lw ra, 0(sp)
    addi sp, sp, 4
    lw t0, (124)(s0)
    addi t0, t0, 4
    sw t0, (124)(s0)
    j done

done:
    mv a0, s0   
    lw  s0, 4(sp)
    lw  ra, 0(sp)
    addi sp, sp, 8

    jalr zero,0(ra)

