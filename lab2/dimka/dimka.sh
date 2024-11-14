nasm -f elf32 dimka.asm -o dimka.o;
ld -m elf_i386 dimka.o -o dimka;
cat "dimka.txt";
echo "";
echo "программа запущена";
./dimka