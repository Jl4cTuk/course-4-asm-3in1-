def common_multiples(m, n):
    limit = m * n
    multiples = []
    
    smaller = min(m, n)
    for i in range(smaller, limit):
        if i % m == 0 and i % n == 0:
            multiples.append(i)
    
    return multiples

m = 20
n = 4
result = common_multiples(m, n)
print(result)