#include <stdio.h>

#define ROWS_A 2
#define COLS_A 3
#define ROWS_B 3
#define COLS_B 2

void matrix_multiply(int A[ROWS_A][COLS_A], int B[ROWS_B][COLS_B], int result[ROWS_A][COLS_B]) {
    for (int i = 0; i < ROWS_A; i++) {
        for (int j = 0; j < COLS_B; j++) {
            result[i][j] = 0;
            for (int k = 0; k < COLS_A; k++) {
                result[i][j] += A[i][k] * B[k][j];
            }
        }
    }
}

void print_matrix(int matrix[ROWS_A][COLS_B], int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
}

int main() {
    int A[ROWS_A][COLS_A] = {
        {1, 2, 3},
        {4, 5, 6}
    };

    int B[ROWS_B][COLS_B] = {
        {7, 8},
        {9, 10},
        {11, 12}
    };

    int result[ROWS_A][COLS_B];

    matrix_multiply(A, B, result);

    printf("Результат умножения матриц:\n");
    print_matrix(result, ROWS_A, COLS_B);

    return 0;
}
