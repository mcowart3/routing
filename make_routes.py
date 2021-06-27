import pandas as pd
from node import Node



def make_routes(dists, times, caps, truckCap, trucks, reals):

    #make integer variables from single-number inputs
    numtrucks = int(trucks.iloc[0, 0])
    truckcapacity = int(truckCap.iloc[0, 0])

    #list of all locations
    nodeList = []

    #variables that track outputs
    totalCap = 0
    totalDist = 0
    route1 = []
    route2 = []
    capList = []
    sumCapList = []
    distList = []
    sumDistList = []
    timeList = []
    sumTimeList = []

    #built list of locations from input
    for i in range(caps.shape[0]):
        nodeList.append(Node(i, caps.iloc[i, 0]))

    #loop to build a route for each truck
    for i in range(numtrucks):

        #variables to track during entire truck route
        loc = 0
        tarList = []
        sumDists = 0
        sumUnits = 0
        sumTimes = 0

        #finds one visited location per loop iteration
        while True:

            #variables to track per location visited
            minDist = 100000
            target = 0
            dist = 0
            cap = 0
            time = 0
            
            #find location with minimized weight that doesn't exceed capacity
            for j in nodeList:

                #avoid identical location, base, any location w/ 0 capacity,
                #or previously visited location
                if j.num == loc or j.num == 0:
                    continue
                if caps.iloc[j.num, 0] == 0:
                    continue
                if not j.visit:
                    #read the inputs to find units available, weighted distance,
                    #real distance, and traveltime
                    newcap = caps.iloc[j.num, 0]
                    newdist = dists.iloc[loc, j.num]
                    realdist = reals.iloc[loc, j.num]
                    newtime = times.iloc[loc, j.num]
                    #realdist2 = realdist + reals.iloc[j.num, 0]
                    #newdist = realdist2/newcap

                    #if valid location, update per-location variables
                    if newdist < minDist and sumUnits + newcap <= truckcapacity:
                        minDist = newdist
                        target = j
                        cap = newcap
                        dist = realdist
                        

            #if no targets available (b/c capacity full), route back to base            
            if target == 0:
                tarList.append(nodeList[0])
                dist = reals.iloc[loc, 0]
                sumDists = sumDists + dist
                distList.append(dist)
                sumCapList.append(sumUnits)
                sumDistList.append(sumDists)
                capList.append(0)
            else:
                #if target found, update relevant variables
                tarList.append(target)
                sumUnits = sumUnits + cap
                capList.append(cap)
                sumDists = sumDists + dist
                distList.append(dist)
                target.visit = True
                loc = target.num
                sumCapList.append(sumUnits)
                sumDistList.append(sumDists)
        
        #build the list of visited locations
        loc = 0
        for i in tarList:
            
            route1.append(loc + 1)
            route2.append(i.num + 1)
            loc = i.num
            
            
##        while count < tempDf.shape[0]:
##            newcap = pickup + tempDf.iloc[count, 1]
##            num = tempDf.iloc[count, 2]
##            if newcap <= truckCap:
##                pickup = newcap
##                route1.append(loc)
##                route2.append(count)
##                nodeList[num].visit = True
##            
##            loc = count
##            count = count + 1

    #build exportable dataframes to output    
    outDic = {'Start':route1, 'End':route2}
    outDf = pd.DataFrame(outDic)
    
    outCapDic = {'Units':capList}
    outCapDf = pd.DataFrame(outCapDic)

    outDistDic = {'Distance':distList}
    outDistDf = pd.DataFrame(outDistDic)

    outSumDistDic = {'Total_Distance':sumDistList}
    outSumDistDf = pd.DataFrame(outSumDistDic)

    outSumUnitsDic = {'Total_Units':sumCapList}
    outSumUnitsDf = pd.DataFrame(outSumUnitsDic)

    return (outDf, outDistDf, outCapDf, outSumDistDf, outSumUnitsDf)
    


