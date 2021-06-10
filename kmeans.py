from k_means_constrained import KMeansConstrained
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
import seaborn as sns
sns.set()

data = pd.read_excel("test.xlsx")
alter = data.to_numpy()

route = KMeansConstrained(n_clusters = 7, size_min = 3, size_max = 3)
route.fit_predict(data)


plt.scatter(alter[:, 0], alter[:, 1], c=route.predict(data), s=50, cmap='viridis')
#centers = route.cluster_centers_
#plt.scatter(centers[:, 0], centers[:, 1], c='black', s=200, alpha=.5)

plt.show()
