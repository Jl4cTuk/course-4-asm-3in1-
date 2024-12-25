#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void insertionSortC(int arr[], int n) {
    int i, key, j;
    for (i = 1; i < n; i++) {
        key = arr[i];
        j = i - 1;

        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j = j - 1;
        }
        arr[j + 1] = key;
    }
}

void insertionSortAsm(int arr[], int n) {
    int i, key, j;
    for (i = 1; i < n; i++) {
        key = arr[i];
        j = i - 1;

        __asm__ __volatile__ (
            "1: \n\t"
            "cmpl %%eax, (%%edi,%%ecx,4) \n\t" // arr[j] > key
            "jle 2f \n\t"
            "movl (%%edi,%%ecx,4), %%edx \n\t" // arr[j] в EDX
            "movl %%edx, 4(%%edi,%%ecx,4) \n\t" // arr[j+1] = arr[j]
            "decl %%ecx \n\t"
            "jge 1b \n\t" // j >= 0
            "2: \n\t"
            : "+c" (j)
            : "D" (arr), "a" (key)
            : "edx", "memory"
        );

        arr[j + 1] = key;
    }
}


void copyArray(int source[], int dest[], int n) {
    for(int i = 0; i < n; i++)
        dest[i] = source[i];
}

int main() {
    int n;
    printf("Введите количество элементов: ");
    if (scanf("%d", &n) != 1 || n <= 0) {
        printf("Некорректный ввод.\n");
        return 1;
    }

    int *original = (int*)malloc(n * sizeof(int));
    int *arrC = (int*)malloc(n * sizeof(int));
    int *arrAsm = (int*)malloc(n * sizeof(int));

    if (!original || !arrC || !arrAsm) {
        printf("Ошибка выделения памяти.\n");
        return 1;
    }

    srand(time(NULL));

    for(int i = 0; i < n; i++) {
        original[i] = rand() % 100000;
    }

    copyArray(original, arrC, n);
    copyArray(original, arrAsm, n);

    clock_t start, end;
    double cpu_time_used_C, cpu_time_used_Asm;

    start = clock();
    insertionSortC(arrC, n);
    end = clock();
    cpu_time_used_C = ((double) (end - start)) / CLOCKS_PER_SEC;

    start = clock();
    insertionSortAsm(arrAsm, n);
    end = clock();
    cpu_time_used_Asm = ((double) (end - start)) / CLOCKS_PER_SEC;

    printf("\nВремя сортировки на C: %.6f секунд\n", cpu_time_used_C);
    printf("Время сортировки с ассемблерными вставками: %.6f секунд\n", cpu_time_used_Asm);
    printf("Разница во времени: %.6f секунд\n", cpu_time_used_C - cpu_time_used_Asm);

    free(original);
    free(arrC);
    free(arrAsm);

    return 0;
}
