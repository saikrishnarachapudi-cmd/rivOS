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
