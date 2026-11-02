.global alloc_pages
.global printMem
.global map_pages
.global table1
.global __free_ram
.global __free_ram_end
.equ PAGE_SIZE, 4096
.equ PAGE_V, 1
.data

__free_ram:
.align 12
table1:
.space 4096
.space 204800
__free_ram_end:
.word 1