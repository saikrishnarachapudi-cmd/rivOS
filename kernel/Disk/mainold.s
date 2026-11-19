.include"struct.inc"
.section .bss
    virt_io_queue:
    VIRT_DESC: .space DESCR_SIZE * VIRTQ_ENTRY_NUM
    AVAIL_RING: .space AVAIL_R_SIZE
    USED_RING:.space USED_R_SIZE
    .balign 4096
    QUEUE_INDEX: .space 4
    USED_IDX_POINTER:.space 4
    LAST_USED_INDEX: .space 2
    DISK_SIZE: .space 4
.text
virtio_blk_init:
    li t0, VIRTIO_BLK_PADDR # address of Virtio_blk info
    lw t1, VIRTIO_REG_MAGIC(t0)
    li t2, 0x74726976
    bne t1, t2, error
    lw t1, VIRTIO_REG_VERSION(t0)
    li t2, 1
    bne t1, t2, error
    lw t1, VIRTIO_REG_DEVICE_ID(t0)
    li t2, VIRTIO_DEVICE_BLK
    bne t1, t2, error
    
    sw x0, VIRTIO_REG_DEVICE_STATUS(t0)
    ori t1, x0, VIRTIO_STATUS_ACK
    ori t1, t1, VIRTIO_STATUS_DRIVER
    sw t1, VIRTIO_REG_DEVICE_STATUS(t0)
    li t1, PAGE_SIZE
    sw t1, VIRTIO_REG_PAGE_SIZE(t0)
    // call virtio_init
    li t0, VIRTIO_BLK_PADDR
    addi t1, x0, VIRTIO_STATUS_DRIVER_OK
    sw t1, VIRTIO_REG_DEVICE_STATUS(t0)
    lw t3, VIRTIO_REG_DEVICE_CONFIG(t0)
    addi t4, x0, SECTOR_SIZE
    mul t3, t3, t4
    la t2, DISK_SIZE
    sw t3, 0(t2)
    addi t0, t3, 0
    jal ra, printHexDebug
    
virtio_init:

error:
    jal ra, error