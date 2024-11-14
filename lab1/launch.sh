nasm -f elf32 sum_digits.asm -o sum_digits.o;
ld -m elf_i386 sum_digits.o -o sum_digits;
echo "программа запущена";
./sum_digits