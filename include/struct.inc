.equ stack_size, 8*1024

#constants
.equ proc_max, 8
.equ page_size, 4*1024
 
#process control block

.equ proc_pid, 0
.equ proc_state,4
.equ proc_sp, 8
.equ proc_satp, 12

.equ proc_size, 16
