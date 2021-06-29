
from make_daily_routes import make_daily_routes
import pandas as pd
from openpyxl import load_workbook

#read inputs from excel 
DISTS = pd.read_excel('routing.xlsm', sheet_name="distances")
TIMES = pd.read_excel('routing.xlsm', sheet_name="times")
UNITS = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="C")
DELIVERIES = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="D")
REALS = pd.read_excel('routing.xlsm', sheet_name="realdists")
TRUCK_CAP = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="F")
NUM_TRUCKS = pd.read_excel('routing.xlsm', sheet_name="unit_entry", usecols="E")


#run the function
output = make_daily_routes(DISTS, TIMES, UNITS, DELIVERIES, TRUCK_CAP, NUM_TRUCKS, REALS)

#print(output)


#write outputs to excel
with pd.ExcelWriter('output.xlsx') as writer:   
    output[0][0].to_excel(writer, sheet_name="m-routes")
    output[0][1].to_excel(writer, sheet_name="m-distances")
    output[0][2].to_excel(writer, sheet_name="m-units")
    output[0][3].to_excel(writer, sheet_name="m-sumDists")
    output[0][4].to_excel(writer, sheet_name="m-sumUnits")
    output[0][5].to_excel(writer, sheet_name="m-times")

    output[1][0].to_excel(writer, sheet_name="t-routes")
    output[1][1].to_excel(writer, sheet_name="t-distances")
    output[1][2].to_excel(writer, sheet_name="t-units")
    output[1][3].to_excel(writer, sheet_name="t-sumDists")
    output[1][4].to_excel(writer, sheet_name="t-sumUnits")
    output[1][5].to_excel(writer, sheet_name="t-times")

    output[2][0].to_excel(writer, sheet_name="w-routes")
    output[2][1].to_excel(writer, sheet_name="w-distances")
    output[2][2].to_excel(writer, sheet_name="w-units")
    output[2][3].to_excel(writer, sheet_name="w-sumDists")
    output[2][4].to_excel(writer, sheet_name="w-sumUnits")
    output[2][5].to_excel(writer, sheet_name="w-times")

    output[3][0].to_excel(writer, sheet_name="th-routes")
    output[3][1].to_excel(writer, sheet_name="th-distances")
    output[3][2].to_excel(writer, sheet_name="th-units")
    output[3][3].to_excel(writer, sheet_name="th-sumDists")
    output[3][4].to_excel(writer, sheet_name="th-sumUnits")
    output[3][5].to_excel(writer, sheet_name="th-times")

    output[4][0].to_excel(writer, sheet_name="f-routes")
    output[4][1].to_excel(writer, sheet_name="f-distances")
    output[4][2].to_excel(writer, sheet_name="f-units")
    output[4][3].to_excel(writer, sheet_name="f-sumDists")
    output[4][4].to_excel(writer, sheet_name="f-sumUnits")
    output[4][5].to_excel(writer, sheet_name="f-times")

    


