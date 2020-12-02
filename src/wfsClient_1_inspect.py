# -*- coding: UTF-8 -*-
#wfsClient_1_inspect.py
from __future__ import absolute_import, division, print_function, unicode_literals
import requests
import json
import pandas as pd
import matplotlib.pyplot as plt

def getObservations(linkWfs: str, parameter: str, proxies: dict) -> pd.Series:
    resultDict = {}
    
    jsonData = None
    r = requests.get(linkWfs), proxies=proxies)
    
    if r.status_code == 200:
        jsonData = json.loads(r.text)
        
        for o in jsonData['features']:
            resultDict.update({o['properties']['phenomenontime']: o['properties']['result']})
    else:
        message = '%s: %s' % (r.status_code, 'Service is down')
        raise ConnectionError(message)
    
    s = pd.Series(resultDict)
    s.name = '%s: %s' % ('FeatureType', parameter)
    return s
    
def main():
    """
    1. Hole jede WFS FeatureClass (Zeitreihe) von https://geodienste.hamburg.de/HH_WFS_Micado_Timeseries
    2. Plotte jede Zeitreihe in einem Line Chart
    """
    proxies = {
        'http': 'http://111.11.111.111:80',
        'https': 'http://111.11.111.111:80',
        }
    
    #classList = ['de.hh.up:auszuege_oeru','de.hh.up:davon_familiennachzuege','de.hh.up:davon_zuzuege_aus_zea_za_ea','de.hh.up:differenz_zugzug_auszug_oeru','de.hh.up:zuzuege_ausserhalb_hh','de.hh.up:zuzuege_oeru']
    classList = ['de.hh.up:nicht_wohnberechtigte_zuwanderer','de.hh.up:summe_zuwanderer_wohnungslose','de.hh.up:wohnberechtigte_zuwanderer','de.hh.up:wohnungslose_jep']
    
    urlStart = 'https://geodienste.hamburg.de/HH_WFS_Micado_Timeseries?service=WFS&request=GetFeature&version=2.0.0&typeName='
    urlEnd = '&outputformat=application/geo%2Bjson'
    
    for element in classList:
        wfsUrl = '%s%s%s' % (urlStart, element, urlEnd)
        s = getObservations(wfsUrl, element, proxies)
        s.plot.line()
        
    #Line Chart aller Zeitreihen
    plt.title('Observations')
    plt.ylabel('Anzahl')
    plt.xlabel('Tag')
    plt.legend()
    plt.show()
    
if __name__ == '__main__':
    main()
    