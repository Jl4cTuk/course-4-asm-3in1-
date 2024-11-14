nasm -f elf -g -F dwarf lab.asm;
ld -m elf_i386 -o lab lab.o;
