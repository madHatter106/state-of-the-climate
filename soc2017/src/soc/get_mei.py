"""Gets MEI DATA to put in a pandas DataFrame"""

import re
import requests
from bs4 import BeautifulSoup as bs
import pandas as pd

URL = 'https://www.esrl.noaa.gov/psd/enso/mei/table.html'


def get_mei_table():
    """Downloads MEI table"""
    response = requests.get(URL)
    return bs(response.text, 'html5lib')


def retrieve_table_data(response_text):
    """regex through downloaded table to retrieve MEI data"""
    header_not_found = True
    table_re = re.compile(r'(^YEAR.+|^19.+|^20.+)')
    for sti in response_text.stripped_strings:
        for si_ in sti.splitlines():
            if table_re.match(si_):
                mylist = re.sub(r'\t|\s+', ',', table_re.findall(si_)[0]).split(',')
                if header_not_found:
                    dfm = pd.DataFrame(columns=mylist)
                    header_not_found = False
                else:
                    dfm = dfm.append({col: elem for col, elem in zip(dfm.columns, mylist)},
                                     ignore_index=True)
    dfm.iloc[:, 1:] = dfm.iloc[:, 1:].astype('float')
    return dfm


if __name__ == "__main__":
    meitexttable = get_mei_table()
    dfmei = retrieve_table_data
