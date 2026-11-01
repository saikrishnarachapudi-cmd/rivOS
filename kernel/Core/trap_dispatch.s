.section .text
.global trap_dispatch
.data
.word 3
ILLEGAL_INST: .ascii ":An Illegal ins"
.word 3
FILE_NAME: .ascii "trap_dispatch.s"
.text
#scause: Why did the trap happen?
#sepc: At which instruction did it happen?
#stval: What additional trap-specific information is available?
#sstatus: What was the CPU's privilege and interrupt state?
#sie / sip: Which supervisor interrupts are enabled or pending?

#t5-interrupt,  scause >> 31;
#t6 - code , scause & 0x7fffffffU;
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

    srli t5,t2,31
    li a0,1
    slli a0,a0,31
    addi a0,a0,-1
    and t6, t2, a0
    li a1,8
    beq t2,a1,env_u
    li a0,1
    slli a0,a0,31
    addi a0,a0,5
    beq a0,t2,timer
    li a0,2
    beq t2,a0,illegal_inst

else:
    #other exception
    jal zero, done    

timer:
    jal ra, sbi_timer
    jal ra, sched_switch
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
    loop: 
        wfi
        jal x0, loop
env_u:
    lw t0, 124(s0)
    addi t0, t0, 4
    sw t0, 124(s0)
    j done

done:
    mv a0, s0   
    lw  s0, 4(sp)
    lw  ra, 0(sp)
    addi sp, sp, 8

    jalr zero,0(ra)

