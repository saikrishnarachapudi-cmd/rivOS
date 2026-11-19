```bash
make build # to build
```
```bash
make run # to run
```

## Text UI (added)
rivOS now has a small text-mode UI over the serial console (ANSI colours):
- **Boot screen** (`kernel/lib/ui.s`): banner + coloured `[ OK ]` boot log.
- **Shell** (`user/shell.s`): prompt, line editing (backspace), commands:
  `help`, `clear`, `banner`, `about`, `echo TEXT`, `colors`, `uptime`, `ps`, `shutdown`.
- **New syscalls**: `SYS_TICKS` (4), `SYS_PROCINFO` (5), `SYS_GETCHAR` (2, non-blocking read, -1 if no input) and
  `SYS_SHUTDOWN` (3, SBI SRST). Wrapper `getChar` in `user/user.s` blocks until a key arrives.
- `kernel/main.s` now starts a single shell process (the other two are commented out).
- Fixed `jalr x0, (ra)` in `kernel/Memory/main.s` (did not assemble with current clang).

Run with a 32-bit OpenSBI; `-bios default` needs QEMU's `opensbi-riscv32-generic-fw_dynamic.bin`.
Press `Ctrl-A X` to quit QEMU, or type `shutdown`.


## Three-task scheduler demo (updated)

`kernel/main.s` now creates three supervisor-mode tasks:
`first_proc`, `second_proc`, and `third_proc`. Each task prints its label
and a countdown. On completion it spins, allowing timer interrupts to keep
scheduling the other tasks. The tasks share a serial console, so lines may
be interleaved. The old shell source is retained but not launched in this mode.

`proc_create(a0)` now uses `a0` as the **supervisor task entry point**.
The initial 52-byte context-switch frame has `ra=proc_start` at offset 0 and
`s0=entry PC` at offset 4, matching `switch_context`. `proc_start` uses
`SPP=1, SPIE=1` for supervisor-mode execution with timer preemption.
The scheduler supplies a separate 8-KiB per-task trap stack in `sscratch`.

Build: `make -r build` (or `make build` on a standard toolchain), then
`make run` if QEMU and a compatible RV32 OpenSBI firmware are installed.
