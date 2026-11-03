.section .text.start
start:
    la sp, __stack_top
    jal ra, main
    jal ra, exit

exit:
    wfi
    jal x0, exit
