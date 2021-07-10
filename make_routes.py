import pandas as pd
from node import Node
from truck import Truck

#constant values
MAX_TIME_TOTAL = 14
MAX_TIME_DRIVING = 11


def make_routes(dists, times, caps, deliveries, truckcapacity, numtrucks, reals, nodeList, truckList, day):

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

    delivList = []

    #truck number
    count = 0
    
    #loop to build a route for each truck
    while count < numtrucks:

        #variables to track during entire truck route
        start = truckList[count].loca
        loc = start
        tarList = []
        sumDists = 0
        sumUnits = truckList[count].units
        sumTimes = 0
        sumDrivingTimes = 0
        deliv = truckList[count].deliv

        #finds one visited location per loop iteration
        while True:

            #variables to track per location visited
            minDist = 100000
            target = 0
            dist = 0
            cap = 0
            time = 0
            newday = False
            allVisit = True
            delivery = 0
            
            
            #find location with minimized weight that doesn't exceed capacity
            for j in nodeList:

                #avoid identical location, base, or previously visited location
                
                if j.num == loc or j.num == 0:
                    continue

                #avoid locations that are scheduled for a different day
                if j.day != "any" and j.day !=day:
                    continue
                
                    
                if not j.visit:

                    
                    #indicate that some locations remain unvisited
                    allVisit = False
                    
                    #read the inputs to find units available, weighted distance,
                    #real distance, and traveltime
                    newcap = caps.iloc[j.num, 0]
                    newdel = deliveries.iloc[j.num, 0]
                    newdist = dists.iloc[loc, j.num]
                    realdist = reals.iloc[loc, j.num]
                    newtime = times.iloc[loc, j.num]

                    #if we have deliveries, we take into account all previous deliveries as well
                    #(since they are pre-loaded)
                    if newdel > 0:
                        
                        #max instead of sum here b/c we could offload deliveries and then load pickups
                        unitsToCompare = max(newdel, newcap) + deliv + sumUnits

                    else:
                        unitsToCompare = sumUnits + newcap

                    #if new minimum or mandatory destination for this day, estimate time required
                    if (newdist < minDist or j.day == day) and unitsToCompare <= truckcapacity:
                        newtime_total = newtime + (newcap + 5)/60

                        #if valid time, update per-location variables (and no longer advance day if we did before)
                        if newtime_total + sumTimes < MAX_TIME_TOTAL and newtime + sumDrivingTimes < MAX_TIME_DRIVING:   

                            delivery = newdel
                            newday = False
                            minDist = newdist
                            target = j
                            cap = newcap
                            dist = realdist
                            time = newtime
                        else:
                            #if we skipped a minimum destination (not a time-mandated destination)
                            #because of time constraints, we tentatively
                            #indicate that the truck should progress to the next day
                            if j.day != day:
                                newday = True
                        

            
                
                            
            #if time to new target exceeds time constraints, keep current truck values
            #and go to next truck
            if newday:

                #store current truck info for next day
                nextDay(truckList[count], loc, sumUnits, deliv)

                #next truck
                
                count = count + 1
                #print(count)
                break;

            #test for case in which capacity reached, but routing back to base
            #would exceed time constraints
            if target == 0:
                testTime = times.iloc[loc, 0]
                testDrivingTime = testTime = sumDrivingTimes
                testTime = testTime + (sumUnits + 5)/60
                testTime = testTime + sumTimes
                
                #in this case, wait until next day before returning to base
                if testDrivingTime > MAX_TIME_DRIVING or testTime > MAX_TIME_TOTAL:
                    nextDay(truckList[count], loc, sumUnits, deliv)

                    #next truck
                    
                    count = count + 1
                    #print(count)
                    break;
                
            #if all locations visited, route back to base         
            if allVisit:
                target = 0
           
            #if no targets available, route back to base            
            if target == 0:
                #update list of destinations
                tarList.append(nodeList[0])

                #update distance traveled
                dist = reals.iloc[loc, 0]
                sumDists = sumDists + dist
                distList.append(dist)

                #update time traveled
                time = times.iloc[loc, 0]
                sumDrivingTimes = sumDrivingTimes + time
                time = time + (sumUnits + 5)/60
                sumTimes = sumTimes + time
                timeList.append(time)

                #update units delivered
                delivList.append(0)
                
                #update total units/distance/time
                sumCapList.append(sumUnits)
                sumDistList.append(sumDists)
                sumTimeList.append(sumTimes)

                #returning to base doesn't pick up units
                capList.append(0)

                #reset unit variables upon return to base
                sumUnits = 0

                #reset truck location
                truckList[count].loca = 0

                #next truck
                count = count + 1
                #print(count)
                break;
            else:
                #if target found, add to route
                tarList.append(target)
                
                #update units picked up
                sumUnits = sumUnits + cap
                capList.append(cap)

                #update units delivered
                delivList.append(delivery)
                deliv = deliv + delivery
                
                #update distance traveled
                sumDists = sumDists + dist
                distList.append(dist)

                #mark the location as visited
                target.visit = True
                loc = target.num

                #update time traveled
                sumDrivingTimes = sumDrivingTimes + time
                time = time + (cap + 5)/60
                sumTimes = sumTimes + time
                timeList.append(time)

                #update total values
                sumCapList.append(sumUnits)
                sumDistList.append(sumDists)
                sumTimeList.append(sumTimes)

                
        
        #build the list of visited locations
        for k in tarList:
            route1.append(start + 1)
            route2.append(k.num + 1)
            start = k.num

        
            
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

    outSumTimesDic = {'Total_Times':sumTimeList}
    outSumTimesDf = pd.DataFrame(outSumTimesDic)

    outDelivDic = {'Deliveries':delivList}
    outDelivDf = pd.DataFrame(outDelivDic)

    return (outDf, outDistDf, outCapDf, outSumDistDf, outSumUnitsDf, outSumTimesDf, outDelivDf)

#stores current truck info for next day    
def nextDay(truck, location, units, deliv):
    truck.loca = location
    truck.units = units
    truck.deliv = deliv
    return

