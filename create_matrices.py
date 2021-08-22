import pandas as pd
import numpy as np
from openpyxl import load_workbook
import googlemaps
import itertools

def create_matrices(addresses, pickups, deliveries):
    maps = googlemaps.Client(key = 'AIzaSyAlrj1tmPvPqtWOixqSEOiydRyKyZiBHjo')
    
    addList = addresses.to_numpy()
    #addList = np.array(addresses)
    total = len(addList)

    order = np.arange(0, total, 1)
    
    #a, b = zip(*list(itertools.product(range(total), range(total))))
    #a, b = np.array(a), np.array(b)
    
    weights = np.zeros(shape=(total, total))
    times = np.zeros(shape=(total, total))
    dists = np.zeros(shape=(total, total))

    for i in range(total):
        for j in range(total):
            result = maps.distance_matrix(addList[i], addList[j])
            dist = result['rows'][0]['elements'][0]['distance']['text']
            dist = " ".join(dist.split(" ")[:-1])
            dist = dist.replace(",", "")
            dist = float(dist)
            
            time = result['rows'][0]['elements'][0]['duration']['text']
            time = " ".join(time.split(" ")[:-1])
            time = time.split(" hour")
            
            #time = time.replace(",", "")
            if len(time) > 1:
                time[1] = time[1].split(" ")[1]
                time = float(time[0]) + (float(time[1]) / 60)
            else:
                time = float(time[0])
            
            weights[i, j] = dist / (max(pickups.iloc[j, 0], deliveries.iloc[j, 0]) + .1)
            times[i, j] = time
            dists[i, j] = dist

    #np.add.at(weights, (a, b), float(" ".join(maps.distance_matrix(addList[a], addList[b])['rows'][0]['elements'][0]['distance']['text'].split(" ")[:-1])))
    
    return(weights, times, dists)
    

