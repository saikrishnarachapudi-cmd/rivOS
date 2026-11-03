.equ stack_size, 8*1024 #8kb
#proc_size = process table entry size
#constants
.equ proc_max, 8
.equ page_size, 4*1024
 
#process control block

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

#scheduler time
.equ cycles, 1000
.equ time_eid, 0x54494D45
.equ time_fid, 0


.equ PAGE_SIZE, 4096
.equ SATP_SV32, 0x80000000
.equ PAGE_V, 0x1
.equ PAGE_R, 0x2
.equ PAGE_W, 0x4
.equ PAGE_X, 0x8
.equ PAGE_U, 0x10
.equ USER_BASE, 0x1000000
