import numpy as np
import matplotlib.pyplot as plt
import sys

# Проверяем, что переданы координаты через аргументы командной строки
if len(sys.argv) != 3:
    print("Использование: python3 graphik.py <x координата> <y координата>")
    sys.exit(1)

# Получаем координаты точки из аргументов командной строки
x_point = float(sys.argv[1])
y_point = float(sys.argv[2])

# Создаем массив значений для x
x = np.linspace(-3, 3, 400)

# Функции y = -x + 2 и y = x - 2
y1 = -x + 2
y2 = x - 2

# Для окружности x^2 + y^2 = 4
theta = np.linspace(0, 2*np.pi, 400)
x_circle = 2 * np.cos(theta)
y_circle = 2 * np.sin(theta)

# Построение графиков
plt.figure(figsize=(8, 8))
plt.plot(x, y1, label="y = -x + 2")
plt.plot(x, y2, label="y = x - 2")
plt.plot(x_circle, y_circle, label="x^2 + y^2 = 4")

# Отображение точки, если она передана
plt.scatter(x_point, y_point, color='red', label=f"Point ({x_point}, {y_point})")

# Настройки графика
plt.xlim(-3, 3)
plt.ylim(-3, 3)
plt.axhline(0, color='black', linewidth=0.5)
plt.axvline(0, color='black', linewidth=0.5)
plt.grid(True)
plt.legend()
plt.gca().set_aspect('equal', adjustable='box')

# Сохраняем график в файл
plt.savefig("graphik.png")

# Завершаем работу matplotlib
plt.close()
