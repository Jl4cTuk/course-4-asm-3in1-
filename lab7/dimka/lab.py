import numpy as np

def move_max_to_top_left(matrix):
    matrix = np.array(matrix)
    max_pos = np.unravel_index(np.argmax(matrix), matrix.shape)

    matrix[[0, max_pos[0]]] = matrix[[max_pos[0], 0]]
    matrix[:, [0, max_pos[1]]] = matrix[:, [max_pos[1], 0]]

    return matrix.tolist()

A = [[5, 12, 3, 9, 14, 2],
    [8, 7, 11, 1, 6, 4],
    [13, 16, 10, 15, 18, 20],
    [21, 17, 19, 22, 24, 23]]

result = move_max_to_top_left(A)
for row in result:
    print(row)
