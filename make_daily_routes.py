import pandas as pd
from node import Node
from make_routes import make_routes
from truck import Truck


def make_daily_routes(dists, times, caps, deliveries, truckCap, trucks, reals, days):
    #classes that require lists to keep track of
    nodeList = []
    truckList = []

    #make integer variables from single-number inputs
    numtrucks = int(trucks.iloc[0, 0])
    print(numtrucks)
    truckcapacity = int(truckCap.iloc[0, 0])
    
    #build lists of classes from input
    for i in range(caps.shape[0]):
        nodeList.append(Node(i, caps.iloc[i, 0], days.iloc[i, 0]))
        
    for i in range(numtrucks):
        truckList.append(Truck(i, 0, 0, 0))
    
    m = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList, "m")
    t = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList, "t")
    w = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList, "w")
    th = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList, "th")
    f = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList, "f")

    

    outTuple = (m, t, w, th, f)

    return outTuple
