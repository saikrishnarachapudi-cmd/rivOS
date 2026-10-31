.include "struct.inc"
    .global scheduler
    .global resume
    .global sched_switch
    .global next_proc
    .global sched_sp

.section .bss
    sched_sp: .space 4
    next_proc: .space 4   ##current iteration

.section .text
    
scheduler:
    csrci sstatus, 2 ##neglecting the interrupts in this stage 
    addi sp,sp,-12
    sw ra,0(sp)
    sw s0, 4(sp) 
    sw s1, 8(sp)  

new_loop:
    la s0, process_table  ##current_proc_number
    li s1, proc_max    ##no.of processes that are not yet seen

outer_loop:
    beqz s1, new_loop   # t2==0
    lw t3, proc_state(s0)
    li t4, proc_ready
    bne t3,t4,resume

    la t0, next_proc
    sw s0, 0(t0)
    li t4, proc_running
    sw t4, proc_state(s0)
#context switching from scheduler to process
    la a0, sched_sp
    addi a1, s0, proc_sp
    jal  ra, switch_context
    
    #back
    lw t0, next_proc
    sw zero, 0(t0)
    li t4, proc_ready
    sw t4, proc_state(t0)

resume:
    li t0, proc_size
    add s0,s0,t0
    addi s1, s1, -1    # t2--
    j outer_loop

#context switching from process to scheduler
sched_switch:
    la t0, next_proc
    lw t0, 0(t0)
    addi a0, t0, proc_sp
    la  a1, sched_sp
    jal ra, switch_context

outer_end:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 12
    ret





