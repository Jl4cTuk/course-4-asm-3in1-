#!/bin/bash

if [ -z "$1" ]; then
  echo "Укажите номер лабораторной работы как параметр"
  exit 1
fi

LAB_DIR="lab$1"
SUBDIRS=("dimka" "kirill" "my")

mkdir -p "$LAB_DIR"

for DIR in "${SUBDIRS[@]}"; do
  mkdir -p "$LAB_DIR/$DIR"

  touch "$LAB_DIR/$DIR/lab.asm"
  touch "$LAB_DIR/$DIR/task.txt"

  cat > "$LAB_DIR/$DIR/launch.sh" << 'EOF'
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
EOF

  chmod +x "$LAB_DIR/$DIR/launch.sh"
done

echo "Структура для лабораторной работы $1 создана"
