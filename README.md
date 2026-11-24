# rivOS

A minimal RISC-V (RV32) teaching OS written in assembly: Sv32 paging, one address space per process,
timer-driven preemptive scheduling, user-mode shell.

```bash
make build      # build kernel.elf (needs clang, lld, llvm-objcopy)
make disk.img   # 64 KiB virtual disk (16 slots x 4096 bytes) for the file syscalls
make run        # run in QEMU (qemu-system-riscv32, 32-bit OpenSBI); Ctrl-A X quits, or type `shutdown`
make demo       # scheduler demo: boots 3 processes (P1,P2,P3) that each print 1..100, then powers off
```

## Layout
- `include/struct.inc` - the single shared constants file (PCB layout, paging flags, syscall numbers)
- `kernel/` boot + main; `Core/` traps and syscalls; `Process/` creation, scheduler, timer;
  `Memory/` page allocator (bump + free list) and Sv32 mapping; `Disk/` semihosting disk; `lib/` stdio/ui
- `user/` shell and programs (`count_up`, `count_down`, `echo_storage`, and the demo processes `proc1`-`proc3` built from `counter_common.inc`)

## Shell commands
`help clear banner about echo colors uptime ps run NAME demo save N TEXT cat N shutdown`
(`demo` spawns P1, P2, P3 from the shell; same output as `make demo`.)

## Syscall ABI (ecall; number in a3, args in a0/a1, result in a0)
0 putchar, 1 putstring, 2 getchar, 3 shutdown, 4 ticks, 5 procinfo, 6 exit, 7 yield,
8 spawn (program index), 9 file_read (slot, buf), 10 file_write (slot, buf)

## Behaviour notes
- A user process that faults is killed with a diagnostic; a fault in the kernel panics and halts.
- Exited processes become zombies; the scheduler frees their pages. When none remain, the machine powers off.
- The disk is the host file `disk.img` accessed via QEMU semihosting (needs `-semihosting-config enable=on,userspace=on`).

## Known limitations
- Untested on real clang in this revision; syscalls/exit/spawn/disk were not exercised end to end.
- User and kernel images are mapped RWX (flat binaries). No blocking wait (shell polls). User pointers are range-checked only.
- The old virtio-blk driver was removed (see git history).
