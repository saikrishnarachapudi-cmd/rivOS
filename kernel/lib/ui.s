# Basic text UI for the kernel (ANSI escape sequences over the serial console)
.global ui_splash
.global kputs

.section .rodata
ui_head:
    .asciz "\033[2J\033[H\033[1;36m\n  +----------------------------------------+\n  |   rivOS  -  RISC-V 32-bit OS  |\n  +----------------------------------------+\033[0m\n\n"
ui_ok:      .asciz "  \033[1;32m[ OK ]\033[0m "
ui_m_trap:  .asciz "trap vector installed (stvec)\n"
ui_m_bss:   .asciz "BSS cleared\n"
ui_m_ram:   .asciz "free RAM  "
ui_to:      .asciz " - "
ui_nl:      .asciz "\n"
ui_m_shell: .asciz "launching shell...\n\n"

.section .text

# a0 = address of NUL-terminated string
kputs:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s2, 4(sp)
    mv s2, a0
kputs_loop:
    lbu a0, 0(s2)
    beqz a0, kputs_done
    jal ra, write_byte
    addi s2, s2, 1
    j kputs_loop
kputs_done:
    lw ra, 0(sp)
    lw s2, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)

ui_splash:
    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, ui_head
    jal ra, kputs

    la a0, ui_ok
    jal ra, kputs
    la a0, ui_m_trap
    jal ra, kputs

    la a0, ui_ok
    jal ra, kputs
    la a0, ui_m_bss
    jal ra, kputs

    la a0, ui_ok
    jal ra, kputs
    la a0, ui_m_ram
    jal ra, kputs
    la a0, __free_ram
    jal ra, printHex
    la a0, ui_to
    jal ra, kputs
    la a0, __free_ram_end
    jal ra, printHex
    la a0, ui_nl
    jal ra, kputs

    la a0, ui_ok
    jal ra, kputs
    la a0, ui_m_shell
    jal ra, kputs

    lw ra, 0(sp)
    addi sp, sp, 4
    jalr x0, 0(ra)
