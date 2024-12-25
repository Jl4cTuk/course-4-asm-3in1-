#include <stdio.h>
#include <math.h>

// Функция для вычисления cos(x) с использованием ряда Тейлора
double calculate_cos(double x, double eps, int *iterations) {
    double term = 1.0; // Первый член ряда
    double result = term; // Итоговая сумма
    double sign = -1.0; // Знак очередного члена
    int n = 2; // Степень (начинаем со второго члена)

    *iterations = 0;

    while (fabs(term) > eps) {
        term *= (x * x) / (n * (n - 1)); // Вычисляем следующий член ряда
        result += sign * term; // Добавляем его к сумме
        sign = -sign; // Меняем знак
        n += 2; // Переходим к следующей степени
        (*iterations)++;
    }

    return result;
}

int main() {
    double x0, eps;
    int iterations;

    // Ввод данных
    printf("x0: ");
    scanf("%lf", &x0);

    printf("EPS: ");
    scanf("%lf", &eps);

    // Вычисление значения функции с использованием ряда Тейлора
    double calculated_value = calculate_cos(x0, eps, &iterations);

    // Вычисление значения с помощью стандартной функции cos
    double standard_value = cos(x0);

    // Вывод результатов
    printf("Рассчитанное значение: %.10f\n", calculated_value);
    printf("Стандартное значение: %.10f\n", standard_value);
    printf("Количество итераций: %d\n", iterations);

    return 0;
}
