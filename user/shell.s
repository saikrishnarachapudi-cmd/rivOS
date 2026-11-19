# rivOS user shell - a small text UI (ANSI colours over the serial console)
    .include "struct.inc"

    .section .rodata
s_banner:
    .asciz "\033[1;36m  +----------------------------------------+\n  |   rivOS  -  RISC-V 32-bit teaching OS  |\n  +----------------------------------------+\033[0m\n  Type \033[1;33mhelp\033[0m to see the available commands.\n\n"
s_hint:     .asciz "  Type \033[1;33mhelp\033[0m to see the available commands.\n\n"
s_prompt:   .asciz "\033[1;32mrivOS\033[1;34m>\033[0m "
s_nl:       .asciz "\n"
s_bs:       .asciz "\b \b"
s_clear:    .asciz "\033[2J\033[H"
s_help:
    .asciz "\033[1mCommands\033[0m\n  help       show this list\n  clear      clear the screen\n  banner     show the rivOS banner\n  about      about this OS\n  echo TEXT  print TEXT\n  colors     show the colour palette\n  uptime     time since boot\n  ps         list processes\n  1          start three demo processes\n  shutdown   power off the machine\n"
s_about:
    .asciz "rivOS: a minimal RISC-V (RV32) OS written in assembly.\n  - Sv32 paging, one address space per process\n  - timer-driven preemptive scheduler\n  - U-mode shell talking to the kernel via ecall\n"
s_unknown1: .asciz "\033[31munknown command:\033[0m "
s_unknown2: .asciz "  (try \033[1;33mhelp\033[0m)\n"
s_bye:      .asciz "\033[1;33mpowering off...\033[0m\n"
s_c1:       .asciz "\033[4"
s_c2:       .asciz "m   \033[0m"

c_help:     .asciz "help"
c_clear:    .asciz "clear"
c_banner:   .asciz "banner"
c_about:    .asciz "about"
c_echo:     .asciz "echo"
c_colors:   .asciz "colors"
c_shutdown: .asciz "shutdown"
c_uptime:   .asciz "uptime"
c_ps:       .asciz "ps"
c_start:    .asciz "1"
s_started: .asciz "Started the three demo processes.\n"
s_again:   .asciz "Demo already started (or no free slots).\n"
s_up1:      .asciz "up "
s_up2:      .asciz " s\n"
s_ps_head:  .asciz "\033[1m  PID  STATE\033[0m\n"
s_sp:       .asciz "  "
s_st0:      .asciz "unused\n"
s_st1:      .asciz "ready\n"
s_st2:      .asciz "running\n"
s_st3:      .asciz "blocked\n"
st_table:   .word s_st0, s_st1, s_st2, s_st3

    .section .text
    .global main

main:
    addi sp, sp, -128
    mv   s0, sp                 # s0 = line buffer
    la   a0, s_hint
    jal  ra, puts
prompt:
    la   a0, s_prompt
    jal  ra, puts
    li   s1, 0                  # s1 = line length
read_loop:
    jal  ra, getChar
    li   t0, 13
    beq  a0, t0, enter
    li   t0, 10
    beq  a0, t0, enter
    li   t0, 127
    beq  a0, t0, backspace
    li   t0, 8
    beq  a0, t0, backspace
    li   t0, 32
    blt  a0, t0, read_loop      # ignore other control characters
    li   t0, 126
    bgt  a0, t0, read_loop
    li   t0, 120
    bge  s1, t0, read_loop      # line full
    add  t1, s0, s1
    sb   a0, 0(t1)
    addi s1, s1, 1
    jal  ra, putChar
    j    read_loop
backspace:
    beqz s1, read_loop
    addi s1, s1, -1
    la   a0, s_bs
    jal  ra, puts
    j    read_loop
enter:
    add  t1, s0, s1
    sb   zero, 0(t1)
    la   a0, s_nl
    jal  ra, puts
    mv   a0, s0
    jal  ra, execute
    j    prompt

# a0 = NUL-terminated string
puts:
    addi sp, sp, -8
    sw   ra, 0(sp)
    sw   s2, 4(sp)
    mv   s2, a0
puts_loop:
    lbu  a0, 0(s2)
    beqz a0, puts_done
    jal  ra, putChar
    addi s2, s2, 1
    j    puts_loop
puts_done:
    lw   ra, 0(sp)
    lw   s2, 4(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)

# a0 = line, a1 = command name
# returns a0 = pointer to the arguments if the first word equals the command, else 0
cmd_is:
cmp_loop:
    lbu  t0, 0(a1)
    beqz t0, cmd_end
    lbu  t1, 0(a0)
    bne  t0, t1, no_match
    addi a0, a0, 1
    addi a1, a1, 1
    j    cmp_loop
cmd_end:
    lbu  t1, 0(a0)
    beqz t1, matched
    li   t2, 32
    bne  t1, t2, no_match
skip_sp:
    lbu  t1, 0(a0)
    li   t2, 32
    bne  t1, t2, matched
    addi a0, a0, 1
    j    skip_sp
matched:
    jalr x0, 0(ra)
no_match:
    li   a0, 0
    jalr x0, 0(ra)

# a0 = input line
execute:
    addi sp, sp, -20
    sw   ra, 0(sp)
    sw   s2, 4(sp)
    sw   s3, 8(sp)
    sw   s4, 12(sp)
    mv   s2, a0
skip_lead:
    lbu  t0, 0(s2)
    li   t1, 32
    bne  t0, t1, lead_done
    addi s2, s2, 1
    j    skip_lead
lead_done:
    beqz t0, exec_ret           # empty line

    mv   a0, s2
    la   a1, c_help
    jal  ra, cmd_is
    bnez a0, do_help
    mv   a0, s2
    la   a1, c_clear
    jal  ra, cmd_is
    bnez a0, do_clear
    mv   a0, s2
    la   a1, c_banner
    jal  ra, cmd_is
    bnez a0, do_banner
    mv   a0, s2
    la   a1, c_about
    jal  ra, cmd_is
    bnez a0, do_about
    mv   a0, s2
    la   a1, c_echo
    jal  ra, cmd_is
    bnez a0, do_echo
    mv   a0, s2
    la   a1, c_colors
    jal  ra, cmd_is
    bnez a0, do_colors
    mv   a0, s2
    la   a1, c_shutdown
    jal  ra, cmd_is
    bnez a0, do_shutdown
    mv   a0, s2
    la   a1, c_uptime
    jal  ra, cmd_is
    bnez a0, do_uptime
    mv   a0, s2
    la   a1, c_ps
    jal  ra, cmd_is
    bnez a0, do_ps

    mv   a0, s2
    la   a1, c_start
    jal  ra, cmd_is
    bnez a0, do_start

    la   a0, s_unknown1
    jal  ra, puts
    mv   a0, s2
    jal  ra, puts
    la   a0, s_nl
    jal  ra, puts
    la   a0, s_unknown2
    jal  ra, puts
    j    exec_ret

do_start:
    jal ra, startDemo
    bnez a0, demo_already
    la a0, s_started
    jal ra, puts
    j exec_ret
demo_already:
    la a0, s_again
    jal ra, puts
    j exec_ret

do_help:
    la   a0, s_help
    jal  ra, puts
    j    exec_ret
do_clear:
    la   a0, s_clear
    jal  ra, puts
    j    exec_ret
do_banner:
    la   a0, s_banner
    jal  ra, puts
    j    exec_ret
do_about:
    la   a0, s_about
    jal  ra, puts
    j    exec_ret
do_echo:
    jal  ra, puts               # a0 still points at the arguments
    la   a0, s_nl
    jal  ra, puts
    j    exec_ret
do_colors:
    li   s3, 0
colors_loop:
    la   a0, s_c1
    jal  ra, puts
    addi a0, s3, 48
    jal  ra, putChar
    la   a0, s_c2
    jal  ra, puts
    addi s3, s3, 1
    li   t0, 8
    blt  s3, t0, colors_loop
    la   a0, s_nl
    jal  ra, puts
    j    exec_ret
do_uptime:
    la   a0, s_up1
    jal  ra, puts
    jal  ra, getTicks
    li   t0, 10000000           # timebase: 10 MHz
    divu a0, a0, t0
    jal  ra, print_uint
    la   a0, s_up2
    jal  ra, puts
    j    exec_ret
do_ps:
    la   a0, s_ps_head
    jal  ra, puts
    li   s3, 0                  # slot index
ps_loop:
    mv   a0, s3
    jal  ra, procInfo
    bltz a0, ps_done
    beqz a0, ps_next            # unused slot
    mv   s4, a0
    la   a0, s_sp
    jal  ra, puts
    mv   a0, s3
    jal  ra, print_uint
    la   a0, s_sp
    jal  ra, puts
    la   a0, s_sp
    jal  ra, puts
    li   t0, 3
    bgtu s4, t0, ps_next
    slli t0, s4, 2
    la   t1, st_table
    add  t1, t1, t0
    lw   a0, 0(t1)
    jal  ra, puts
ps_next:
    addi s3, s3, 1
    j    ps_loop
ps_done:
    j    exec_ret
do_shutdown:
    la   a0, s_bye
    jal  ra, puts
    addi a3, x0, SYS_SHUTDOWN
    ecall
halt:
    j    halt

exec_ret:
    lw   ra, 0(sp)
    lw   s2, 4(sp)
    lw   s3, 8(sp)
    lw   s4, 12(sp)
    addi sp, sp, 20
    jalr x0, 0(ra)

# a0 = unsigned number, prints it in decimal
print_uint:
    addi sp, sp, -32
    sw   ra, 28(sp)
    addi t2, sp, 24             # write digits backwards from sp+24
    sb   zero, 0(t2)
    li   t3, 10
pu_loop:
    remu t0, a0, t3
    divu a0, a0, t3
    addi t0, t0, 48
    addi t2, t2, -1
    sb   t0, 0(t2)
    bnez a0, pu_loop
    mv   a0, t2
    jal  ra, puts
    lw   ra, 28(sp)
    addi sp, sp, 32
    jalr x0, 0(ra)
