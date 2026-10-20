
QEMU     := qemu-system-riscv32
CC       := clang
LD       := ld.lld

CFLAGS   := --target=riscv32-unknown-elf \
            -std=c11 -O2 -g3 -Wall -Wextra \
            -fno-stack-protector -ffreestanding -nostdlib \
            -march=rv32imac_zicsr -Iinclude

ASFLAGS  := --target=riscv32-unknown-elf \
            -g3 -march=rv32imac_zicsr -Iinclude

TARGET   := kernel.elf
OBJECT   := kernel.o
MAPFILE  := kernel.map
LDSCRIPT := kernel.ld
TMPDIR   := .build

# Automatically discover source files in the project directories
SOURCES := $(shell find kernel lib user -type f \
           \( -name '*.S' -o -name '*.s' -o -name '*.c' \) \
           2>/dev/null | sort)

.PHONY: all build run start clean FORCE

all: build

build: $(TARGET)

# Force a fresh combined object so additions and deletions are detected
FORCE:

$(OBJECT): FORCE $(SOURCES)
	@set -e; \
	rm -rf $(TMPDIR); \
	mkdir -p $(TMPDIR); \
	objs=""; \
	for src in $(SOURCES); do \
	    rel="$${src#./}"; \
	    obj="$(TMPDIR)/$${rel%.*}.o"; \
	    mkdir -p "$$(dirname "$$obj")"; \
	    case "$$src" in \
	        *.c) \
	            $(CC) $(CFLAGS) -c "$$src" -o "$$obj" ;; \
	        *.S|*.s) \
	            $(CC) $(ASFLAGS) -c "$$src" -o "$$obj" ;; \
	    esac; \
	    objs="$$objs $$obj"; \
	done; \
	if [ -z "$$objs" ]; then \
	    echo "Error: No source files found"; \
	    exit 1; \
	fi; \
	$(LD) -r $$objs -o $(OBJECT); \
	rm -rf $(TMPDIR)

# Link the combined object into the final executable
$(TARGET): $(OBJECT) $(LDSCRIPT)
	$(CC) --target=riscv32-unknown-elf \
	      -fuse-ld=lld -nostdlib \
	      -Wl,-T,$(LDSCRIPT) \
	      -Wl,-Map=$(MAPFILE) \
	      $(OBJECT) -o $@

run: start

start: $(TARGET)
	$(QEMU) -machine virt -bios default \
	        -nographic -serial mon:stdio \
	        --no-reboot -kernel $(TARGET)

clean:
	rm -rf $(TMPDIR)
	rm -f $(OBJECT) $(TARGET) $(MAPFILE)
