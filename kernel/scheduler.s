.include "struct.inc"
    .global scheduler
    .global resume

.section .text
    
scheduler:
    la t0,proc_stacks
    li t2, proc_max

outer_loop:
    beqz t2, outer_end   # t2==0
    lw t3, proc_state(t0)
    li t4, proc_ready
    bne t3,t4,inner_end
    lw a0, proc_sp(t0)
    jal ra, switch_context
    li t1, cycles    #reset, t1=cycles

    jal ra,sbi_timer
resume:
    addi t0,t0,proc_size
    addi t2, t2, -1    # t2--
    j outer_loop            

outer_end:


