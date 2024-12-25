#include <stdio.h>
#include <math.h>

// Функция для вычисления значения y
float calculate_y(float x) {
    // Проверяем, чтобы знаменатель не был равен 0
    float denominator = x * x - 5 * x + 6;
    return (x - 1) / denominator + cbrt(2 * x + 1);
}

int main() {
    // Заданный диапазон значений x и шаг
    float start = 4.0;
    float end = 5.0;
    float step = 0.1;

    printf("x y\n");
    for (float x = start; x <= end; x += step) {
        float y = calculate_y(x);
        printf("%.2f %.6f\n", x, y);
    }

    return 0;
}
