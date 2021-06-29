import pandas as pd
from node import Node
from make_routes import make_routes
from truck import Truck


def make_daily_routes(dists, times, caps, deliveries, truckCap, trucks, reals):
    #classes that require lists to keep track of
    nodeList = []
    truckList = []

    #make integer variables from single-number inputs
    numtrucks = int(trucks.iloc[0, 0])
    truckcapacity = int(truckCap.iloc[0, 0])
    
    #build lists of classes from input
    for i in range(caps.shape[0]):
        nodeList.append(Node(i, caps.iloc[i, 0]))
        
    for i in range(numtrucks):
        truckList.append(Truck(i, 0, 0))
    
    m = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList)
    t = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList)
    w = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList)
    th = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList)
    f = make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList)

    

    outTuple = (m, t, w, th, f)

    return outTuple
