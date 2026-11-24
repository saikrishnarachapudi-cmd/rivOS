.include "struct.inc"
.section .rodata
msg_kill1:   .asciz "\n\033[1;31m[ trap ] process "
msg_kill2:   .asciz " killed: scause="
msg_sepc:    .asciz " sepc="
msg_stval:   .asciz " stval="
msg_nl:      .asciz "\033[0m\n"
msg_panic:   .asciz "\n\033[1;31m[ KERNEL PANIC ] unexpected trap in supervisor mode: scause="

.section .text
.global trap_dispatch

# Trap frame (built by trap_entry): x1..x31 at 0..120, sepc 124, sstatus 128,
# scause 132, stval 136.
# a0 = pointer to the frame; the frame to resume is returned in a0.
#
#   user ecall            -> syscall_dispatch (Core/syscall.s)
#   supervisor timer      -> re-arm the timer, preempt the process
#   other interrupts      -> ignored
#   fault in user mode    -> print a diagnostic, kill only that process
#   fault in kernel mode  -> kernel panic, halt
trap_dispatch:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    mv   s0, a0

    lw   t2, 132(s0)             # scause
    bgez t2, td_exception        # interrupt bit clear -> synchronous exception
    li   t0, 0x80000005          # supervisor timer interrupt
    beq  t2, t0, td_timer
    j    done                    # any other interrupt: ignore

td_exception:
    li   t0, 8                   # environment call from U-mode
    beq  t2, t0, td_syscall
    lw   t0, 128(s0)             # saved sstatus
    andi t0, t0, 0x100           # SPP: 1 = trap came from supervisor mode
    bnez t0, kernel_fault

    # ---- user fault: kill the offending process only ----
    la   a0, msg_kill1
    jal  ra, kputs
    la   t0, next_proc
    lw   t0, 0(t0)
    lw   a0, proc_pid(t0)
    jal  ra, printInt
    la   a0, msg_kill2
    jal  ra, kputs
    lw   a0, 132(s0)
    jal  ra, printHex
    la   a0, msg_sepc
    jal  ra, kputs
    lw   a0, 124(s0)
    jal  ra, printHex
    la   a0, msg_stval
    jal  ra, kputs
    lw   a0, 136(s0)
    jal  ra, printHex
    la   a0, msg_nl
    jal  ra, kputs
    la   t0, next_proc
    lw   t0, 0(t0)
    li   t1, proc_zombie
    sw   t1, proc_state(t0)      # scheduler reaps it
    jal  ra, sched_switch        # never returns for a zombie
killed_hang:
    wfi
    j    killed_hang

kernel_fault:
    la   a0, msg_panic
    jal  ra, kputs
    lw   a0, 132(s0)
    jal  ra, printHex
    la   a0, msg_sepc
    jal  ra, kputs
    lw   a0, 124(s0)
    jal  ra, printHex
    la   a0, msg_stval
    jal  ra, kputs
    lw   a0, 136(s0)
    jal  ra, printHex
    la   a0, msg_nl
    jal  ra, kputs
panic_hang:
    wfi
    j    panic_hang

td_timer:
    jal  ra, sbi_timer
    jal  ra, sched_switch
    j    done

td_syscall:
    mv   a0, s0
    jal  ra, syscall_dispatch
    j    done

done:
    mv a0, s0
    lw  s0, 4(sp)
    lw  ra, 0(sp)
    addi sp, sp, 8
    jalr zero,0(ra)
