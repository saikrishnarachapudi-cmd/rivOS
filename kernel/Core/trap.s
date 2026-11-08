.include "struct.inc"
.section .text

.global trap_entry
.section .text
.align 2

.global trap_entry


# Trap frame layout: 160 bytes
# x1-x31: offsets 0-120
# sepc:   offset 124
# sstatus:offset 128
# scause: offset 132
# stval:  offset 136
#scause: Why did the trap happen?
#sepc: At which instruction did it happen?
#stval: What additional trap-specific information is available?
#sstatus: What was the CPU's privilege and interrupt state?
#sie / sip: Which supervisor interrupts are enabled or pending?


trap_entry:
    
    csrrw sp, sscratch, sp
    
    addi sp, sp, -160

    # Save general-purpose registers
    sw ra,   0(sp)
    sw t0,  16(sp)

    
    addi t0, sp, 160
    sw t0,   4(sp)

    sw gp,   8(sp)
    sw tp,  12(sp)

    sw t1,  20(sp)
    sw t2,  24(sp)
    sw s0,  28(sp)
    sw s1,  32(sp)

    sw a0,  36(sp)
    csrr t0, sepc
    csrr t0, scause
    sw a1,  40(sp)
    sw a2,  44(sp)
    sw a3,  48(sp)
    sw a4,  52(sp)
    sw a5,  56(sp)
    sw a6,  60(sp)
    sw a7,  64(sp)

    sw s2,  68(sp)
    sw s3,  72(sp)
    sw s4,  76(sp)
    sw s5,  80(sp)
    sw s6,  84(sp)
    sw s7,  88(sp)
    sw s8,  92(sp)
    sw s9,  96(sp)
    sw s10, 100(sp)
    sw s11, 104(sp)

    sw t3, 108(sp)
    sw t4, 112(sp)
    sw t5, 116(sp)
    sw t6, 120(sp)

    # Save trap CSRs
    csrr t0, sepc
    sw t0, 124(sp)
    csrr t0, sstatus
    sw t0, 128(sp)

    csrr t0, scause
    sw t0, 132(sp)

    csrr t0, stval
    sw t0, 136(sp)

    csrr t0, sscratch
    sw t0, 144(sp)

    # Pass pointer to trap frame to the dispatcher
    mv a0, sp
    jal ra, trap_dispatch

    # Dispatcher returns the frame to resume in a0.
    
    # Initially it should return the same frame.
    mv sp, a0

    # Restore trap CSRs
    lw t0, 124(sp)
    csrw sepc, t0

    lw t0, 128(sp)
    csrw sstatus, t0

    lw t0, 144(sp)
    csrw sscratch, t0

    # Restore registers
    lw ra,   0(sp)
    lw gp,   8(sp)
    lw tp,  12(sp)

    lw t1,  20(sp)
    lw t2,  24(sp)
    lw s0,  28(sp)
    lw s1,  32(sp)

    lw a0,  36(sp)
    lw a1,  40(sp)
    lw a2,  44(sp)
    lw a3,  48(sp)
    lw a4,  52(sp)
    lw a5,  56(sp)
    lw a6,  60(sp)
    lw a7,  64(sp)

    lw s2,  68(sp)
    lw s3,  72(sp)
    lw s4,  76(sp)
    lw s5,  80(sp)
    lw s6,  84(sp)
    lw s7,  88(sp)
    lw s8,  92(sp)
    lw s9,  96(sp)
    lw s10, 100(sp)
    lw s11, 104(sp)

    lw t3, 108(sp)
    lw t4, 112(sp)
    lw t5, 116(sp)
    lw t6, 120(sp)
    lw t0,  16(sp)

    
    lw sp, 4(sp)
    
    csrrw sp, sscratch, sp
    


    sret