.section .text
.global trap_dispatch

# a0 = pointer to the trap frame (built by trap_entry)
# scause is at 132(frame)
# returns a0 = frame to resume (same frame)
#
# Only the supervisor timer interrupt is handled:
# re-arm the timer, then give the CPU back to the scheduler.
# sched_switch returns here when this process is scheduled again.
trap_dispatch:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    mv   s0, a0                 # s0 = frame (survives the context switch)

    lw   t2, 132(s0)            # scause
    li   t1, 0x80000005         # interrupt bit | 5 = supervisor timer
    bne  t2, t1, halt           # anything else is not handled

    jal  ra, sbi_timer          # re-arm timer (clears pending STIP)
    jal  ra, sched_switch       # returns when rescheduled

    mv   a0, s0                 # resume the same frame
    lw   s0, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 16
    jalr zero, 0(ra)

halt:
    wfi
    j    halt