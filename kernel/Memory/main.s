.include "struct.inc"
.global printMem
.global alloc_pages
.global map_pages
.global free_page
.global free_address_space
.global free_list_count
.data
freeRamPointer: .word 0
freeListHead: .word 0
.word 13
OUT_OF_MEMORY:.ascii "Out or memory"
.word 13
FILE_NAME: .ascii "Memory/main.s"
.word 33
UNALIGNED_ADDR: .ascii "memory not aligned with page size"
.text
printMem:
    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, __free_ram
    #jal ra, printHex
    addi a0, x0, 32
    //jal ra, write_byte
    la a0, freeRamPointer
    la t0, __free_ram
    sw t0, 0(a0)
    addi a0, t0, 0
    #jal ra, printHex
    addi a0, x0, 32
    //jal ra, write_byte
    la a0, __free_ram_end
    #jal ra, printHex

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)

# number of pages in a0
# final address in a0
# Single pages are recycled from the free list (and zeroed); larger requests
# and an empty free list are served by the bump pointer.
# Clobbers only t0-t5 (callers rely on that).
alloc_pages:
    addi sp, sp, -4
    sw ra, 0(sp)
    la t1, freeRamPointer
    lw t2, 0(t1)
    bnez t2, 1f
    la t2, __free_ram          # lazy init: no longer depends on printMem
    sw t2, 0(t1)
1:
    li t3, 1
    bne a0, t3, alloc_bump
    la t4, freeListHead
    lw t5, 0(t4)
    beqz t5, alloc_bump
    lw t0, 0(t5)               # next free page
    sw t0, 0(t4)
    mv t0, t5                  # zero the recycled page
    li t3, PAGE_SIZE
    add t3, t3, t5
2:
    sw zero, 0(t0)
    addi t0, t0, 4
    bltu t0, t3, 2b
    mv a0, t5
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
alloc_bump:
    li t3, PAGE_SIZE
    mul t0, a0, t3             # bytes requested
    mv t4, t2                  # return value
    add t2, t2, t0             # new end
    la t5, __free_ram_end
    bltu t5, t2, error         # out of memory
    sw t2, 0(t1)
    mv a0, t4
    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
error:
    la a0, OUT_OF_MEMORY
    la a1, FILE_NAME
    addi a2, x0, 62
    jal ra, panic
halt_oom:                      # fatal: never hand out a bogus address
    wfi
    j halt_oom

# a0 = page-aligned address of a page that came from alloc_pages
# pushes it on the free list; anything else is ignored
free_page:
    slli t0, a0, 20            # low 12 bits must be zero (page aligned)
    bnez t0, 1f
    la t0, __free_ram
    bltu a0, t0, 1f
    la t0, __free_ram_end
    bgeu a0, t0, 1f
    la t1, freeListHead
    lw t2, 0(t1)
    sw t2, 0(a0)
    sw a0, 0(t1)
1:
    jalr x0, 0(ra)

# a0 = satp value of a process
# frees every user page (PAGE_U leaves), every second-level table and the
# root table. Kernel pages are shared between processes and are never freed.
free_address_space:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    li t0, 0x3fffff
    and a0, a0, t0
    slli s0, a0, 12            # root table address
    li s1, 0                   # level-1 index
fas_l1:
    li t0, 1024
    bgeu s1, t0, fas_done
    slli t0, s1, 2
    add t0, t0, s0
    lw t1, 0(t0)
    andi t2, t1, PAGE_V
    beqz t2, fas_l1_next
    andi t2, t1, 0xE           # R/W/X set = superpage leaf, none are created
    bnez t2, fas_l1_next
    srli t1, t1, 10
    slli s2, t1, 12            # level-2 table address
    li s3, 0
fas_l2:
    li t0, 1024
    bgeu s3, t0, fas_l2_done
    slli t0, s3, 2
    add t0, t0, s2
    lw t1, 0(t0)
    andi t2, t1, PAGE_V
    beqz t2, fas_l2_next
    andi t2, t1, PAGE_U
    beqz t2, fas_l2_next       # kernel mapping: shared
    srli t1, t1, 10
    slli a0, t1, 12
    jal ra, free_page
fas_l2_next:
    addi s3, s3, 1
    j fas_l2
fas_l2_done:
    mv a0, s2
    jal ra, free_page
fas_l1_next:
    addi s1, s1, 1
    j fas_l1
fas_done:
    mv a0, s0
    jal ra, free_page
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    jalr x0, 0(ra)

# returns the number of pages currently sitting on the free list in a0
free_list_count:
    la t0, freeListHead
    lw t0, 0(t0)
    li a0, 0
1:
    beqz t0, 2f
    addi a0, a0, 1
    lw t0, 0(t0)
    j 1b
2:
    jalr x0, 0(ra)

# a0 processVirtualAdressTablePointer
# a1 start virtual address of the page
# a2 start physical address of the page
# a3 flags
# it maps the given virtual page to the given physical page
# may override existing pages
map_pages:
    # check if vaddr and paddr are aligned(It is needed because PTEs have physical addresses which are 12 bit aligned)
    srli t0, a1, 12
    srli t1, a2, 12
    slli t0, t0, 12
    slli t1, t1, 12
    bne t0, a1, alignmentError
    bne t1, a2, alignmentError
    #Get vpn1 which is the offset of pagetable entry in primary pagetable
    srli t2, a1, 22
    andi t2, t2, 0x3ff
    #Get the table entry of the required page
    addi t3, x0, 4 #PTE width
    mul t2, t2, t3 #PTE offset
    add t2, t2, a0
    lw t4, 0(t2)# PTE of table 1 in t4
    andi t5, t4, PAGE_V # to check if valid
    bne t5, x0, pageExists
        #primary pagetable doesnt exists so make it
        addi sp, sp, -44
        sw a0, 0(sp)
        sw a1, 4(sp)
        sw a2, 8(sp)
        sw a3, 12(sp)
        sw ra, 16(sp)
        sw t0, 20(sp)
        sw t1, 24(sp)
        sw t2, 28(sp)
        sw t3, 32(sp)
        sw t4, 36(sp)
        sw t5, 40(sp)
        addi a0, x0, 1
        jal ra, alloc_pages
        addi t6, a0, 0#t6 has the paddress of the new table
        lw a0, 0(sp)
        lw a1, 4(sp)
        lw a2, 8(sp)
        lw a3, 12(sp)
        lw ra, 16(sp)
        lw t0, 20(sp)
        lw t1, 24(sp)
        lw t2, 28(sp)
        lw t3, 32(sp)
        lw t4, 36(sp)
        lw t5, 40(sp)
        
        addi sp, sp, 44
        #map it
        srli t6, t6, 12#physical address to
        slli t6, t6, 10#PTE
        ori t6, t6, PAGE_V
        sw t6, 0(t2)
        addi t4, t6, 0
    pageExists:
        addi t6, a1, 0#vpn0 second level 
        srli t6, t6, 12#vpn0 in t6
        andi t6, t6, 0x3ff
        
        srli t4, t4, 10
        slli t4, t4, 12# PTE to physical address

        srli a2, a2, 12
        slli a2, a2, 10
        ori a2, a2, PAGE_V# physical address to PTE
        or a2, a2, a3

        mul t6, t6, t3
        add t6, t6, t4
        sw a2, 0(t6)
        jalr x0, 0(ra)

    alignmentError:
        addi sp, sp, -4
        sw ra, 0(sp)
        addi a0, a1, 0
        jal ra, printHex
        addi a0, a2, 0
        jal ra, printHex
        la a0, UNALIGNED_ADDR
        la a1, FILE_NAME
        addi a2, x0, 154
        jal ra, panic
    halt_align:                # fatal: mapping an unaligned page is a kernel bug
        wfi
        j halt_align
