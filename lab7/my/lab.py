def sum_shaded_area(matrix):
    n = len(matrix)
    total_sum = 0

    for i in range(n // 2 + 1):
        total_sum += sum(matrix[i][i:n - i])

    for i in range(n // 2 + 1, n):
        total_sum += sum(matrix[i][n - i - 1:i + 1])
    
    return total_sum

matrix = [
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 5, 6, 7, 8, 9]
]

print("Сумма элементов из заштрихованной области:", sum_shaded_area(matrix))