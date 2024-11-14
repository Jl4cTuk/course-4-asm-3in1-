#!/bin/bash

rm -f *.o lab

nasm -f elf32 lab.asm -o lab.o
ld -m elf_i386 lab.o -o lab

if [ $? -eq 0 ]; then
    echo "Программа запущена"
    ./lab
else
    echo "Ошибка при компиляции или линковке"
fi
