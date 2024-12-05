#include <stdio.h>

// Функция для проверки, сравнимы ли два числа
int are_comparable(unsigned int a, unsigned int b) {
    for (int i = 0; i < sizeof(int); i++) {
        int bit_a = (a >> i) & 1;
        int bit_b = (b >> i) & 1;
        
        // Если bit_a == 1, то bit_b должно быть тоже 1, иначе вектора несравнимы
        if (bit_a == 1 && bit_b == 0) {
            return 0;  // Несравнимы
        }
    }
    return 1;  // Сравнимы
}

// Функция для упорядочивания a так, чтобы оно стало меньше или равно b
unsigned int order_vectors(unsigned int a, unsigned int b) {
    unsigned int result = a;
    for (int i = 0; i < sizeof(int); i++) {
        int bit_a = (a >> i) & 1;
        int bit_b = (b >> i) & 1;
        
        // Если bit_a == 0 и bit_b == 1, можно изменить bit_a на 1
        if (bit_a == 0 && bit_b == 1) {
            result |= (1 << i);  // Устанавливаем бит на позиции i в 1
        }
    }
    return result;
}

int main() {
    unsigned int a = 13, b = 14;
    // for (unsigned int a = 1; a<=100; a++)
    //     for (unsigned int b = 1; b<=100; b++)
            if (are_comparable(a, b))
                printf("Сравнимы %u, %u\n", a, b);
            else printf("Не сравнимы\n");
    return 0;
}
