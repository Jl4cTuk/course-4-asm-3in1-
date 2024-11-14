nasm -f elf32 lab.asm -o lab.o;
ld -m elf_i386 lab.o -o lab;
echo "программа запущена";
./lab