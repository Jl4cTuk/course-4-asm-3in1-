def func(X, Y):
    C = []
    n = len(X)
    for x in X:
        for i in range(n - 1):
            if Y[i] < x < Y[i + 1]:
                C.append(x)
                break
    m = len(C)
    return m, C

X = [3, 7, 10, 15, 20]
Y = [5, 8, 12, 18, 19]
m, C = func(X, Y)

print("X:",X)
print("Y:",Y)
print(f"m: {m}")
print(f"C: {C}")
