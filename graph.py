import pandas as pd
import node

TRUCK_CAP = 50
NUM_TRUCKS = 3

dists = pd.read_excel('routing.xlsx', sheet_name="distances")
caps = pd.read_excel('routing.xlsx', sheet_name="capacities")



def make_routes(dists, caps, truckCap, trucks):
    nodeList = []
    totalCap = 0
    route1 = []
    route2 = []
    routeList = []
    for i in range(len(caps.index)):
        nodeList[i] = new Node(i, caps.iloc[0, i])

    for i in range(NUM_TRUCKS):
        pickup = 0
        tarList = []
        capList = []
        numList = []
        
        for j in nodeList:
            newcap = caps.iloc[0, j]
            ratio = newcap / dists.iloc[i, j]
            if not j.visit:
                tarList.append(ratio)
                capList.append(newcap)
                numList.append(j)
            
        tempDic = {'r':tarList, 'c':capList, 'n':numList}
        tempDf = pd.DataFrame(tempDic)
        tempDf.sort_values(by=['r'], ascending=False)
        
        count = 0
        loc = 0
        while True:
            newcap = pickup + tempDf.iloc[count, 1]
            num = tempDf.iloc[count, 2]
            if newcap <= TRUCK_CAP:
                pickup = newcap
                route1.append(loc)
                route2.append(count)
                nodeList[num].visit = True
            else:
                break
            loc = count
            count = count + 1

        outDic = {'s':route1, 'e':route2}
        outDf = pd.DataFrame(outDic)
        
        totalCap = totalCap + pickup
        routeList.append(outDf)
    return (totalCap, routeList)
    


