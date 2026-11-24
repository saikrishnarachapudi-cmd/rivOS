# ---------------------------------------------------------------
# rivOS shared constants (single copy - every Makefile uses -I<root>/include)
# ---------------------------------------------------------------

# --- memory / paging ---
.equ PAGE_SIZE, 4096
.equ SATP_SV32, 0x80000000
.equ PAGE_V, 0x1
.equ PAGE_R, 0x2
.equ PAGE_W, 0x4
.equ PAGE_X, 0x8
.equ PAGE_U, 0x10
.equ USER_BASE, 0x1000000

# --- process control block ---
.equ stack_size, 8*1024 #8kb kernel stack per process
.equ proc_max, 8
.equ page_size, 4*1024

.equ proc_pid, 0
.equ proc_state,4
.equ proc_sp, 8
.equ proc_satp, 12
.equ kp_stack, 16
.equ proc_size, 4112

.equ proc_unused,    0
.equ proc_ready,     1
.equ proc_running,   2
.equ proc_blocked,   3
.equ proc_zombie,    4   # exited, waiting for the scheduler to free its pages

# --- scheduler time ---
.equ cycles, 1000
.equ time_eid, 0x54494D45
.equ time_fid, 0

# --- system calls (user: number in a3, args in a0/a1, result in a0) ---
.equ SYS_PUTCHAR,    0
.equ SYS_PUTSTRING,  1   # a0 = NUL-terminated string address
.equ SYS_GETCHAR,    2
.equ SYS_SHUTDOWN,   3
.equ SYS_TICKS,      4
.equ SYS_PROCINFO,   5
.equ SYS_EXIT,       6
.equ SYS_YIELD,      7
.equ SYS_SPAWN,      8   # a0 = program index -> pid or -1
.equ SYS_FILE_READ,  9   # a0 = slot (1-based), a1 = 4096-byte buffer -> 0 / -1
.equ SYS_FILE_WRITE, 10  # a0 = slot (1-based), a1 = 4096-byte buffer -> 0 / -1

.equ NUM_PROGRAMS, 6     # spawnable: count_up, count_down, echo_storage, proc1, proc2, proc3
.equ DISK_SLOT_SIZE, 4096
.equ DISK_SLOTS, 16

# --- QEMU semihosting operations (a0 = op, a1 = argument block) ---
.equ SH_OPEN,   0x01
.equ SH_CLOSE,  0x02
.equ SH_WRITEC, 0x03
.equ SH_WRITE0, 0x04
.equ SH_WRITE,  0x05
.equ SH_READ,   0x06
.equ SH_READC,  0x07
.equ SH_SEEK,   0x0A
