#include <stdio.h>

#define ROWS 3
#define COLS 3

void move_max_to_top_left(int matrix[ROWS][COLS]) {
    int max_value = matrix[0][0];
    int max_row = 0, max_col = 0;

    // Находим координаты максимального элемента
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            if (matrix[i][j] > max_value) {
                max_value = matrix[i][j];
                max_row = i;
                max_col = j;
            }
        }
    }

    // Переставляем строки: строку с max элементом перемещаем на первую строку
    if (max_row != 0) {
        for (int j = 0; j < COLS; j++) {
            int temp = matrix[0][j];
            matrix[0][j] = matrix[max_row][j];
            matrix[max_row][j] = temp;
        }
    }

    // Переставляем столбцы: столбец с max элементом перемещаем на первый столбец
    if (max_col != 0) {
        for (int i = 0; i < ROWS; i++) {
            int temp = matrix[i][0];
            matrix[i][0] = matrix[i][max_col];
            matrix[i][max_col] = temp;
        }
    }
}

void print_matrix(int matrix[ROWS][COLS]) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
}

int main() {
    int matrix[ROWS][COLS] = {
        {3, 4, 1},
        {5, 9, 2},
        {8, 7, 6}
    };

    printf("Original matrix:\n");
    print_matrix(matrix);

    move_max_to_top_left(matrix);

    printf("\nMatrix after moving max to top-left:\n");
    print_matrix(matrix);

    return 0;
}
