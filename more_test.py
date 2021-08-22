import numpy as np
import itertools

# your original array
x = np.array([1, 4, 8, 99, 77, 23, 4, 45])
n = len(x)
# all pairs of indices in x
a, b = zip(*list(itertools.product(range(n), range(n))))
a, b = np.array(a), np.array(b)
# resulting matrix
result = np.zeros(shape=(n, n))

np.add.at(result, (a, b), (x[a] + x[b]) / 2.0)
print(result)
