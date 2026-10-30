.section .text
.global trap_dispatch

#scause: Why did the trap happen?
#sepc: At which instruction did it happen?
#stval: What additional trap-specific information is available?
#sstatus: What was the CPU's privilege and interrupt state?
#sie / sip: Which supervisor interrupts are enabled or pending?

#t5-interrupt,  scause >> 31;
#t6 - code , scause & 0x7fffffffU;
trap_dispatch:
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
    slli a0,a0,30
    addi a0,a0,5
    beq a0,t2,timer
    li a0,2
    beq t2,a0,illegal_inst

timer:
    
    jalr zero,0(ra)

illegal_inst:

    jalr zero,0(ra)
    
env_u:
    jalr zero,0(ra)