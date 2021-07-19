
from make_daily_routes import make_daily_routes
import pandas as pd
from write import write

#read inputs from excel 
DISTS = pd.read_excel('routing.xlsm', sheet_name="distances")
TIMES = pd.read_excel('routing.xlsm', sheet_name="times")
UNITS = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="C")
DELIVERIES = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="D")
REALS = pd.read_excel('routing.xlsm', sheet_name="realdists")
truckcap = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="G")
TRUCK_CAP = int(truckcap.iloc[0, 0])
numtrucks = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="F")
NUM_TRUCKS = int(numtrucks.iloc[0, 0])
DAYS = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="E")

#run the function
output = make_daily_routes(DISTS, TIMES, UNITS, DELIVERIES, TRUCK_CAP, NUM_TRUCKS, REALS, DAYS)

#write to excel
write(output, NUM_TRUCKS)

    


