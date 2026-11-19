
user_entry:
    addi a0, x0, 66
    jal ra, write_byte
    loop:
        wfi
        jal ra, loop