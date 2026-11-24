.include "struct.inc"
# User system calls.
#   number in a3, arguments in a0/a1, result written back into the saved a0.
#   sepc is advanced past the ecall before dispatch so a process resumes
#   after it, whatever the handler does (yield, exit, ...).

.global syscall_dispatch

.section .rodata
.balign 4
# spawnable programs: { size, start, end }
program_table:
    .word _binary_count_up_bin_size,     _binary_count_up_bin_start,     _binary_count_up_bin_end
    .word _binary_count_down_bin_size,   _binary_count_down_bin_start,   _binary_count_down_bin_end
    .word _binary_echo_storage_bin_size, _binary_echo_storage_bin_start, _binary_echo_storage_bin_end
    .word _binary_proc1_bin_size,        _binary_proc1_bin_start,        _binary_proc1_bin_end
    .word _binary_proc2_bin_size,        _binary_proc2_bin_start,        _binary_proc2_bin_end
    .word _binary_proc3_bin_size,        _binary_proc3_bin_start,        _binary_proc3_bin_end

.section .text

# a0 = trap frame pointer
syscall_dispatch:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    mv   s0, a0
    lw   a3, 48(s0)              # syscall number
    lw   a0, 36(s0)              # argument 0
    lw   a1, 40(s0)              # argument 1
    lw   t0, 124(s0)             # skip the ecall instruction
    addi t0, t0, 4
    sw   t0, 124(s0)

    li   t0, SYS_PUTCHAR
    beq  a3, t0, sc_putchar
    li   t0, SYS_PUTSTRING
    beq  a3, t0, sc_putstring
    li   t0, SYS_GETCHAR
    beq  a3, t0, sc_getchar
    li   t0, SYS_SHUTDOWN
    beq  a3, t0, sc_shutdown
    li   t0, SYS_TICKS
    beq  a3, t0, sc_ticks
    li   t0, SYS_PROCINFO
    beq  a3, t0, sc_procinfo
    li   t0, SYS_EXIT
    beq  a3, t0, sc_exit
    li   t0, SYS_YIELD
    beq  a3, t0, sc_yield
    li   t0, SYS_SPAWN
    beq  a3, t0, sc_spawn
    li   t0, SYS_FILE_READ
    beq  a3, t0, sc_file_read
    li   t0, SYS_FILE_WRITE
    beq  a3, t0, sc_file_write
    li   a0, -1                  # unknown syscall -> -1
    j    sc_return

sc_return:                       # a0 = result
    sw   a0, 36(s0)
sc_done:
    lw   ra, 0(sp)
    lw   s0, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)

sc_putchar:
    jal  ra, write_byte
    li   a0, 0
    j    sc_return

# a0 = user address of a NUL-terminated string (at most 4096 bytes are printed)
sc_putstring:
    mv   a1, a0
    li   a0, 1
    jal  ra, user_range_ok       # at least the first byte must be a user address
    beqz a0, sc_fail
    mv   s1, a1
    li   s2, 4096
sc_ps_loop:
    beqz s2, sc_ps_end
    lbu  a0, 0(s1)
    beqz a0, sc_ps_end
    jal  ra, write_byte
    addi s1, s1, 1
    addi s2, s2, -1
    j    sc_ps_loop
sc_ps_end:
    li   a0, 0
    j    sc_return

sc_fail:
    li   a0, -1
    j    sc_return

# non-blocking: byte or -1 (SBI legacy console_getchar)
sc_getchar:
    li   a7, 2
    ecall
    j    sc_return

sc_shutdown:
    li   a7, 0x53525354
    li   a6, 0
    li   a0, 0
    li   a1, 0
    ecall
sc_shutdown_hang:
    wfi
    j    sc_shutdown_hang

sc_ticks:
    rdtime a0
    j    sc_return

# a0 = slot -> state (0 unused, 1 ready, 2 running, 3 blocked, 4 zombie) or -1
sc_procinfo:
    li   t0, proc_max
    bgeu a0, t0, sc_fail
    li   t0, proc_size
    mul  t0, t0, a0
    la   t1, process_table
    add  t1, t1, t0
    lw   a0, proc_state(t1)
    j    sc_return

# the calling process becomes a zombie; the scheduler frees its memory
sc_exit:
    la   t0, next_proc
    lw   t0, 0(t0)
    li   t1, proc_zombie
    sw   t1, proc_state(t0)
    jal  ra, sched_switch        # never returns
sc_exit_hang:
    wfi
    j    sc_exit_hang

sc_yield:
    jal  ra, sched_switch        # comes back when we are scheduled again
    li   a0, 0
    j    sc_return

# a0 = program index (0 count_up, 1 count_down, 2 echo_storage) -> pid or -1
sc_spawn:
    li   t0, NUM_PROGRAMS
    bgeu a0, t0, sc_fail
    li   t0, 12
    mul  t0, t0, a0
    la   t1, program_table
    add  t1, t1, t0
    lw   a0, 0(t1)               # size
    lw   a1, 4(t1)               # start
    lw   a2, 8(t1)               # end
    jal  ra, proc_create
    j    sc_return

# a0 = slot (1-based), a1 = user buffer of 4096 bytes -> 0 on success, else -1
sc_file_read:
    jal  ra, file_args_ok
    beqz a0, sc_fail
    mv   a0, a1                  # buffer
    lw   a1, 36(s0)              # slot
    jal  ra, getFileContent
    j    sc_return
sc_file_write:
    jal  ra, file_args_ok
    beqz a0, sc_fail
    mv   a0, a1
    lw   a1, 36(s0)
    jal  ra, saveFileContent
    j    sc_return

# checks the slot in saved a0 and the buffer in saved a1 -> a0 = 1 ok / 0 bad
# (a1 = buffer is preserved)
file_args_ok:
    addi sp, sp, -4
    sw   ra, 0(sp)
    lw   t0, 36(s0)
    beqz t0, fa_bad
    li   t1, DISK_SLOTS
    bgtu t0, t1, fa_bad
    lw   a1, 40(s0)
    li   a0, DISK_SLOT_SIZE
    jal  ra, user_range_ok
    j    fa_end
fa_bad:
    li   a0, 0
fa_end:
    lw   ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)

# a1 = user pointer, a0 = length -> a0 = 1 if [a1, a1+a0) lies in the user
# window [USER_BASE, 0x1800000), else 0. Preserves a1.
user_range_ok:
    li   t0, USER_BASE
    bltu a1, t0, ur_bad
    add  t1, a1, a0
    bltu t1, a1, ur_bad          # wrapped around
    li   t0, 0x1800000
    bgtu t1, t0, ur_bad
    li   a0, 1
    jalr x0, 0(ra)
ur_bad:
    li   a0, 0
    jalr x0, 0(ra)
