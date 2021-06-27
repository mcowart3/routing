from make_routes import make_routes
import pandas as pd
from openpyxl import load_workbook

#read inputs from excel 
DISTS = pd.read_excel('routing.xlsm', sheet_name="distances")
TIMES = pd.read_excel('routing.xlsm', sheet_name="times")
UNITS = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="C")
REALS = pd.read_excel('routing.xlsm', sheet_name="realdists")
TRUCK_CAP = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="F")
NUM_TRUCKS = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="E")

#run the function
output = make_routes(DISTS, TIMES, UNITS, TRUCK_CAP, NUM_TRUCKS, REALS)

print(output)


#write outputs to excel
with pd.ExcelWriter('output.xlsx') as writer:

    
    output[0].to_excel(writer, sheet_name="routes")
    output[1].to_excel(writer, sheet_name="distances")
    output[2].to_excel(writer, sheet_name="units")
    output[3].to_excel(writer, sheet_name="sumDists")
    output[4].to_excel(writer, sheet_name="sumUnits")


