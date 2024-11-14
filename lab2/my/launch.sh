nasm -f elf32 lab2.asm -o lab2.o;
ld -m elf_i386 lab2.o -o lab2;
echo "программа запущена";
./lab2