nasm -f elf32 kirill.asm -o kirill.o;
ld -m elf_i386 kirill.o -o kirill;
echo "программа запущена";
./kirill