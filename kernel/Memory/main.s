.include "struct.inc"
.global printMem
.global alloc_pages
.global map_pages
.data
freeRamPointer: .word 0
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
    jal ra, printHex
    addi a0, x0, 32
    jal ra, write_byte
    la a0, freeRamPointer
    la t0, __free_ram
    sw t0, 0(a0)
    addi a0, t0, 0
    jal ra, printHex
    addi a0, x0, 32
    jal ra, write_byte
    la a0, __free_ram_end
    jal ra, printHex

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, (ra)

// number of pages in a0
// final address in a0
alloc_pages:
    addi sp , sp, -4
    sw ra, 0(sp)
    addi t0, a0, 0 // number of pages
    la t1, freeRamPointer // pointer to freeRamPointer
    lw t2, 0(t1) // freeRamPointer Value
    li t3, PAGE_SIZE

    mul t0, t0, t3 // space to alloc in t0
    addi t4, t2, 0 // return value in t4
    add t2, t0, t2 // end address in t2
    la t5, __free_ram_end

    bge t2, t5, error// error if end is out of limit

    lw ra, 0(sp)
    addi sp, sp, 4
    addi a0, t4, 0
    sw t2, 0(t1)
    jalr x0, 0(ra)
    error:
        la a0, OUT_OF_MEMORY
        la a1, FILE_NAME
        addi a2, x0, 62

        jal ra, panic
        lw ra, 0(sp)
        addi sp, sp, 4
        addi a0, t4, 0
        jalr x0, 0(ra)
// a0 processVirtualAdressTablePointer
// a1 start virtual address of the page
// a2 start physical address of the page
// a3 flags
// it maps the given virtual page to the given physical page
// may override existing pages
map_pages:
    // check if vaddr and paddr are aligned(It is needed because PTEs have physical addresses which are 12 bit aligned)
    srli t0, a1, 12
    srli t1, a2, 12
    slli t0, t0, 12
    slli t1, t1, 12
    bne t0, a1, alignmentError
    bne t1, a2, alignmentError
    //Get vpn1 which is the offset of pagetable entry in primary pagetable
    srli t2, a1, 22
    andi t2, t2, 0x3ff
    //Get the table entry of the required page
    addi t3, x0, 4 //PTE width
    mul t2, t2, t3 //PTE offset
    add t2, t2, a0
    lw t4, 0(t2)// PTE of table 1 in t4
    andi t5, t4, PAGE_V // to check if valid
    bne t5, x0, pageExists
        //primary pagetable doesnt exists so make it
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
        addi t6, a0, 0//t6 has the paddress of the new table
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
        //map it
        srli t6, t6, 12//physical address to
        slli t6, t6, 10//PTE
        ori t6, t6, PAGE_V
        sw t6, 0(t2)
        addi t4, t6, 0
    pageExists:
        addi t6, a1, 0//vpn0 second level 
        srli t6, t6, 12//vpn0 in t6
        andi t6, t6, 0x3ff
        
        srli t4, t4, 10
        slli t4, t4, 12// PTE to physical address

        srli a2, a2, 12
        slli a2, a2, 10
        ori a2, a2, PAGE_V// physical address to PTE
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
        lw ra, 0(sp)
        addi sp, sp, 4
        addi a0, t4, 0
        jalr x0, 0(ra)


