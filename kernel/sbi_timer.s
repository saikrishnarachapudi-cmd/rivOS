.include "struct.inc"

#  current 64-bit time counter into t1:t0
rdtime t0
rdtimeh t1

###addition in parts

li t2, 1000000
add t0, t0, t2
sltu t3, t0, t2 
add t1, t1, t3   # Carry into upper 32 bits

# Pass the absolute timer value in a1:a0
mv      a0, t0
mv      a1, t1

li a6,time_fid
li a7,time_eid

ecall