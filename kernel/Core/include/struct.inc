.equ stack_size, 8*1024 #8kb

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

#sys call
.equ SYS_PUTCHAR, 0
.equ SYS_PUTSTRING, 1