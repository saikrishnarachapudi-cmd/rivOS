.include "struct.inc"
    .global scheduler
    .global resume
    .global sched_switch
    .global next_proc
    .global sched_sp

.section .bss
    sched_sp: .space 4
    next_proc: .space 4   ##current iteration (next process control block)

.section .rodata
msg_all_exited: .asciz "\n\033[1;33m[ rivOS ] all processes have exited - powering off\033[0m\n"

.section .text

# Round-robin scheduler. Runs forever on the boot stack with S-interrupts off.
#  * zombies (exited processes) are reaped here, after we have left their
#    address space, so their page tables can be freed safely
#  * when nothing is ready the CPU idles in wfi
#  * when no process is alive at all the machine is powered off
scheduler:
    csrci sstatus, 2 ##neglecting the interrupts in this stage
    addi sp,sp,-12
    sw ra,0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    new_loop:
        # --- count live (t2) and ready (t3) processes ---
        la t0, process_table
        li t1, proc_max
        li t2, 0
        li t3, 0
    scan:
        beqz t1, scan_done
        lw t4, proc_state(t0)
        beqz t4, scan_next
        addi t2, t2, 1
        li t5, proc_ready
        bne t4, t5, scan_next
        addi t3, t3, 1
    scan_next:
        li t5, proc_size
        add t0, t0, t5
        addi t1, t1, -1
        j scan
    scan_done:
        beqz t2, all_exited
        bnez t3, run_scan
        wfi                       # processes exist but none is ready: idle
        j new_loop

    run_scan:
        la s0, process_table  ##current_proc_number
        li s1, proc_max    ##no.of processes that are not yet seen

        outer_loop:
            beq s1, x0, new_loop
            lw t3, proc_state(s0)
            li t4, proc_ready
            bne t3,t4,resume
            satpDebug:
            sfence.vma
            lw a0, proc_satp(s0)
            csrw satp, a0
            sfence.vma

            la t0, next_proc
            sw s0, 0(t0)
            li t4, proc_running
            sw t4, proc_state(s0)
        #context switching from scheduler to process
            la a0, sched_sp
            addi a1, s0, proc_sp
            lw t0, proc_sp(s0)
            csrw sscratch, t0
            jal  ra, switch_context

            #back in the scheduler: leave the process address space first
            csrw satp, zero
            sfence.vma
            lw t0, next_proc
            lw t3, proc_state(t0)
            li t4, proc_running
            beq t3, t4, back_ready      # preempted or yielded
            li t4, proc_zombie
            bne t3, t4, resume          # anything else: leave state alone
            # exited: free its pages and recycle the slot
            lw a0, proc_satp(t0)
            jal ra, free_address_space
            lw t0, next_proc
            sw zero, proc_state(t0)
            sw zero, proc_satp(t0)
            j resume
        back_ready:
            li t4, proc_ready
            sw t4, proc_state(t0)

    resume:
        li t0, proc_size
        add s0,s0,t0
        addi s1, s1, -1    # t2--
        j outer_loop

    all_exited:
        la a0, msg_all_exited
        jal ra, kputs
        li a7, 0x53525354        # SBI SRST
        li a6, 0
        li a0, 0
        li a1, 0
        ecall
    halt_all:
        wfi
        j halt_all

#context switching from process to scheduler
sched_switch:
    addi sp, sp, -4
    sw ra, 0(sp)
    la t0, next_proc
    lw t0, 0(t0)
    addi a0, t0, proc_sp
    la  a1, sched_sp
    jal ra, switch_context
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
