.global boot
boot:
    la sp, __stack_top
    jal ra, kernel_main