QEMU    := qemu-system-riscv32
CC      := clang
ROOT    := $(abspath .)
CFLAGS  := -std=c11 -g3 -Wall -Wextra \
           --target=riscv32-unknown-elf -fuse-ld=lld -nostdlib \
           -march=rv32ima_zicsr -I$(ROOT)/include

SUBDIRS := kernel kernel/Process kernel/Core kernel/Memory kernel/lib kernel/Disk user
.PHONY: build libs $(SUBDIRS) run demo host clean

build: libs kernel.elf
libs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ ROOT=$(ROOT)

OBJS := kernel/Core/core.o kernel/Process/process.o kernel/lib/lib.o kernel/boot.o \
        kernel/Memory/memory.o kernel/Disk/disk.o \
        user/shell.bin.o user/count_up.bin.o user/count_down.bin.o user/echo_storage.bin.o \
        user/proc1.bin.o user/proc2.bin.o user/proc3.bin.o

kernel.elf: libs
	$(CC) $(CFLAGS) $(OBJS) -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf

# 64 KiB virtual disk used by the file syscalls (16 slots of 4096 bytes)
disk.img:
	dd if=/dev/zero of=disk.img bs=4096 count=16 2>/dev/null

QEMU_FLAGS := -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
              -semihosting -semihosting-config enable=on,target=native,userspace=on

run: kernel.elf disk.img
	$(QEMU) $(QEMU_FLAGS) -kernel kernel.elf

# 3 processes (P1,P2,P3) scheduled round-robin, each printing 1..100; no shell.
# kernel/boot.o is rebuilt with -Wa,-defsym,DEMO=1; the machine powers off when all have exited.
demo: disk.img
	rm -f kernel/boot.o kernel.elf
	$(MAKE) build EXTRA="-Wa,-defsym,DEMO=1"
	$(QEMU) $(QEMU_FLAGS) -kernel kernel.elf
	@rm -f kernel/boot.o kernel.elf   # so a later 'make run' rebuilds the normal shell kernel

host: kernel.elf disk.img
	$(QEMU) -gdb tcp::9000 -S $(QEMU_FLAGS) -kernel kernel.elf

clean:
	rm -f kernel.elf kernel.map
	find . -type f \( -name "*.o" -o -name "*.bin" -o -name "*.elf" \) -not -path "./.git/*" -delete
