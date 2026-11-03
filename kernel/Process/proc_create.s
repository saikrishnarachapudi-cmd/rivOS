.include "struct.inc"
###returns the new process sp in a1.
#ra = proc_start 
#s0 = entry point
.section .rodata
    m:
    .ascii "out of space for another process"
    .equ len, 32

.section .text 
    .global proc_create

#pid = 0,1,2...max-1
# returns a0 = pid  or -1 if the process table is full
proc_create:
    la t0, process_table
    li t2, proc_max # counter for process tables
    li t3, 0  #t3=pid of new process
    check:
        beq t2,zero,full # t2 is zero so no process empty
        lw t1, proc_state(t0)
        beq t1,zero, create # t1 is empty go there
        li t5, proc_size          
        add t0, t0, t5
        addi t3, t3, 1
        addi t2, t2, -1
        jal x0, check

    create:
        sw t3, proc_pid(t0) # store as new pid
        li t1, proc_ready
        sw t1, proc_state(t0)     
        //---------------------------
        addi sp, sp, -32
        sw t0, 0(sp)
        sw t1, 4(sp)
        sw t2, 8(sp)
        sw t3, 12(sp)
        sw t4, 16(sp)
        sw t5, 20(sp)
        sw a0, 24(sp)
        sw ra, 28(sp)
        jal ra, map_kernel_pages
        srli a0, a0, 12
        addi t1, x0, 1
        slli t1, t1, 31# and with the top bit set to one to enable sv32
        or a0, t1, a0
        lw t0, 0(sp)
        sw a0, proc_satp(t0)
        lw t1, 4(sp)
        lw t2, 8(sp)
        lw t3, 12(sp)
        lw t4, 16(sp)
        lw t5, 20(sp)
        lw a0, 24(sp)
        lw ra, 28(sp)
        addi sp, sp, 32
    //---------------------------

#stack top: proc_stacks + (pid + 1) * stack_size
    la t1, proc_stacks
    addi t4, t3, 1
    li t5, stack_size
    mul t4, t4, t5
    add t1, t1, t4        # t1 = top of stack

    #t4-stack size
    li t4, stack_size
    srli t4, t4, 2 
    mv t5, t1       

    zero_frame:# clear the stack into zeros
        addi t5, t5, -4 
        sw zero, 0(t5) 
        addi t4, t4, -1  
        bnez t4, zero_frame

    #switch_context frame
    addi t1, t1, -52
    la t2, proc_start
    sw t2, 0(t1)      #ra = proc_start
    sw a0, 4(t1)      #s0 = entry point
    sw t1, proc_sp(t0)
    
    
    mv a0, t3 
    mv a1, t1 
    jalr zero, 0(ra)         

full:
    addi sp, sp, -8
    sw ra, 0(sp)
    li a0, len
    la a1, m
    jal ra, write_string
    li a0, -1
    lw ra, 0(sp)
    addi sp, sp, 8
    jalr zero, 0(ra)

proc_start:
    csrsi sstatus, 2
    jalr zero, (s0)

//maps all kernel pages for a process
// returns process table address value in a0
map_kernel_pages:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi a0, x0, 1
    jal ra, alloc_pages
    addi t2, a0, 0 // process adress table in t2
    la t0, __kernel_base
    la t1, __free_ram_end
    addi t3, x0, 1
    slli t3, t3, 12//Page size in t3

    start_mapping:
        bge t0, t1, done_map
        addi a0, t2, 0
        addi a1, t0, 0
        addi a2, t0, 0
        addi a3, x0, 0
        ori a3, a3, PAGE_R
        ori a3, a3, PAGE_X
        ori a3, a3, PAGE_W
        addi sp, sp, -16
        sw t0, 0(sp)
        sw t1, 4(sp)
        sw t2, 8(sp)
        sw t3, 12(sp)

        jal ra, map_pages
        lw t0, 0(sp)
        lw t1, 4(sp)
        lw t2, 8(sp)
        lw t3, 12(sp)
        addi sp, sp, 16
        add t0, t0, t3
        jal x0, start_mapping
    
    done_map:
    // copy process address table to t2
    addi a0, t2, 0
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)


#a0 - start of image
#a1 - end of image
#a2 - size of image
#a3 - processPageTableAddress
map_user_pages:
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)
    li s3, PAGE_SIZE # fixed
    addi s4, x0, 0
    ori s4, s4, PAGE_V
    ori s4, s4, PAGE_X
    ori s4, s4, PAGE_R
    ori s4, s4, PAGE_W
    ori s4, s4, PAGE_U
    addi s0, s3, 0 # end of currently allocated storage
    addi s1, a2, 0 # max size
    addi s2, a3, 0
    map_loop:
        bge s0, s1, compltedFullPages
        addi a0, x0, 1
        jal ra, alloc_pages
        addi a2, a0, 0
        addi a0, s2, 0
        addi a3, s4, 0
        addi a1, s0, 0 # start of current page
        jal ra, map_pages
        add s0, s0, s3
        jal x0, map_loop
    compltedFullPages:
        sub s0, s0, s3
        blt s0, s1, return
            addi a0, x0, 1
            jal ra, alloc_pages
            addi a2, a0, 0
            addi a0, s2, 0
            addi a3, s4, 0
            addi a1, s0, 0 # start of current page
            jal ra, map_pages
    return:
        lw s0, 0(sp)
        lw s1, 4(sp)
        lw s2, 8(sp)
        lw s3, 12(sp)
        lw s4, 16(sp)
        lw ra, 20(sp)
        addi sp, sp, 24
        jalr x0, 0(ra)
