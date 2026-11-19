#include <stdio.h>
#include <stdlib.h>
extern int table1[];
extern int alloc_pages(int num);
extern int map_pages(int *table1, int vaddr, int paddr, int flags);
extern void printMem();
int virtualToPhysical(int *table1, int vaddr)
{
    // printf("VPN1 %d\n", (vaddr >> 22) & 0x3ff);
    // printf("VPN0 %d\n", (vaddr >> 12) & 0x3ff);
    int pte1 = table1[(vaddr >> 22) & 0x3ff];
    // printf("Pagetable entry of level1 is %x\n", pte1);
    if ((pte1 & 1) == 0)
    {
        return 0;
    }
    int *table0 = (int *)((pte1 >> 10) << 12);
    int pte0 = table0[(vaddr >> 12) & 0x3ff];
    if ((pte0 & 1) == 0)
    {
        return 0;
    }
    // printf("Pagetable entry of level0 is %x\n", pte0);
    // printf("padr without offet %x\n", (pte0 >> 10));
    return ((pte0 >> 10) << 12) | (vaddr & 0xfff);
}
int main()
{
    printf("Helloworld");
    printMem();
    printf("\n");
    int page = alloc_pages(1);
    printf("0x%x", page);
    // printf("\n");
    // printf("%x", alloc_pages(1));
    // printf("\n");
    // printf("%x", alloc_pages(1));
    // printf("\n");
    // printf("%x", alloc_pages(1));
    printf("\n");
    // printf("%x",map_pages(table1, 0x0, 0x7f05c, 1)); error
    printf("0x%x", map_pages(table1, page, page, 1));
    // printf("%x", table1[(vaddr >> 22) & 0x3ff]);
    for (int i = 0; i < 4097; i++)
    {
        printf("vaddr: %x paddr: ", page + i);
        int paddr = virtualToPhysical(table1, page + i);
        if (paddr != 0)
        {
            printf("%x\n", paddr);
        }
        else
        {
            printf("Not mapped\n");
        }
    }
}
void panic(char *mes, char *file, int line)
{
    printf("panic %s, %s, %d", mes, file, line);
    exit(1);
}
void printHex(int num)
{
    printf(" %x ", num);
}
void write_byte(int num)
{
    printf("%c", num);
}