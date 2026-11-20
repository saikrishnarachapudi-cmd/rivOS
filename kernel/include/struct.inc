# Shared kernel-only constants. Included by all kernel subdirectories.

# Process configuration
.equ stack_size, 1024
.equ proc_max, 8
.equ page_size, 4*1024

# Process control block: four 32-bit fields, 16 bytes total
.equ proc_pid, 0
.equ proc_state, 4
.equ proc_sp, 8
.equ proc_satp, 12
.equ proc_size, 16

.equ proc_unused, 0
.equ proc_ready, 1
.equ proc_running, 2
.equ proc_blocked, 3

# Timer/SBI constants
.equ cycles, 1000
.equ time_eid, 0x54494D45
.equ time_fid, 0

# Kernel syscall IDs (must match user/include/struct.inc)
.equ SYS_PUTCHAR, 0
.equ SYS_PUTSTRING, 1
.equ SYS_GETCHAR, 2
.equ SYS_SHUTDOWN, 3
.equ SYS_TICKS, 4
.equ SYS_PROCINFO, 5
.equ SYS_START_DEMO, 6

# Virtual memory constants
.equ PAGE_SIZE, 4096
.equ SATP_SV32, 0x80000000
.equ PAGE_V, 0x1
.equ PAGE_R, 0x2
.equ PAGE_W, 0x4
.equ PAGE_X, 0x8
.equ PAGE_U, 0x10
.equ USER_BASE, 0x1000000
