import pandas as pd
from openpyxl import load_workbook

def write(output, trucks):
    with pd.ExcelWriter('output.xlsx') as writer:
        days = ["m", "t", "w", "th", "f"]
        for i in range(5):
            for j in range(trucks):
                day = days[i]
                truck = str(j)
                index = i * trucks + j
                output[index][0].to_excel(writer, sheet_name=day+"-"+truck+"-"+"routes")
                output[index][1].to_excel(writer, sheet_name=day+"-"+truck+"-"+"distances")
                output[index][2].to_excel(writer, sheet_name=day+"-"+truck+"-"+"units")
                output[index][3].to_excel(writer, sheet_name=day+"-"+truck+"-"+"sumDists")
                output[index][4].to_excel(writer, sheet_name=day+"-"+truck+"-"+"sumUnits")
                output[index][5].to_excel(writer, sheet_name=day+"-"+truck+"-"+"times")
                output[index][6].to_excel(writer, sheet_name=day+"-"+truck+"-"+"deliveries")
            for j in range(10-trucks):
                day = days[i]
                truck = str(j + trucks)
                target = pd.DataFrame([0, 0])
                target.to_excel(writer, sheet_name=day+"-"+truck+"-"+"routes")
                target.to_excel(writer, sheet_name=day+"-"+truck+"-"+"distances")
                target.to_excel(writer, sheet_name=day+"-"+truck+"-"+"units")
                target.to_excel(writer, sheet_name=day+"-"+truck+"-"+"sumDists")
                target.to_excel(writer, sheet_name=day+"-"+truck+"-"+"sumUnits")
                target.to_excel(writer, sheet_name=day+"-"+truck+"-"+"times")
                target.to_excel(writer, sheet_name=day+"-"+truck+"-"+"deliveries")

        
