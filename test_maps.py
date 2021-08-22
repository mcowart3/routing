import googlemaps
import re

maps = googlemaps.Client(key = 'AIzaSyAlrj1tmPvPqtWOixqSEOiydRyKyZiBHjo')

result = maps.distance_matrix("Sydney Town Hall",
                                     "Parramatta, NSW")
a = result['rows'][0]['elements'][0]['distance']['text']
b = result['rows'][0]['elements'][0]['duration']['text']

#print(re.findall("\d+\.\d+", a))
print(a)
