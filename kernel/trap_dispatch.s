.section .text
.global trap_dispatch

#scause: Why did the trap happen?
#sepc: At which instruction did it happen?
#stval: What additional trap-specific information is available?
#sstatus: What was the CPU's privilege and interrupt state?
#sie / sip: Which supervisor interrupts are enabled or pending?

trap_dispatch:
    csrr t0,sepc
    csrr t1,sstatus
    csrr t2,scause
    csrr t3,stval
    csrr t4, sie

    srli t5,t2,31
    li a0,1
    beq t5,a0,time
    
time:
