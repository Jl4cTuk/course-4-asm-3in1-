import math

def solve_quadratic(a, b, c):
    # Вычисляем дискриминант
    discriminant = b**2 - 4*a*c
    print(f"Дискриминант: {discriminant}")
    
    if discriminant > 0:
        # Два различных корня
        root1 = (-b + math.sqrt(discriminant)) / (2*a)
        root2 = (-b - math.sqrt(discriminant)) / (2*a)
        return root1, root2
    elif discriminant == 0:
        # Один корень (два совпадающих)
        root = -b / (2*a)
        return root, root
    else:
        # Комплексные корни
        real_part = -b / (2*a)
        imaginary_part = math.sqrt(abs(discriminant)) / (2*a)
        return (real_part + imaginary_part * 1j), (real_part - imaginary_part * 1j)

# Пример для решения уравнения: 1x^2 + -3x + 2 = 0
a = 1
b = -7
c = 12
print(a, b, c)
roots = solve_quadratic(a, b, c)
print(roots)