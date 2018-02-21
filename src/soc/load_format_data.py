from datetime import datetime
import pandas as pd


def convert_secs2dt(sec):
    """
    Converts seconds to python datetime object.
    :param sec
        float seconds
    :return:
        datetime object
    """
    zd00 = datetime(2000, 1, 1)
    zd70 = datetime(1970, 1, 1)
    offset = (zd00 - zd70).total_seconds()
    z = datetime.utcfromtimestamp(sec + offset)
    return z


def get_doy(secs):
    """
    Converts seconds to fractional day of year.
    :param secs
        float seconds
    :return:
        fractional day of year
    """
    z = convert_secs2dt(secs)
    y = z.year
    return (secs + (datetime(2000, 1, 1) - datetime(y, 1, 1)).total_seconds()) / 86400


def load_format_data(filepath, minimal=True):
    """
    Loads chlorophyll data into a pandas dataframe,
    formats time entries, and creates a datetime index.
    :param filepath:
        string or pathlib object
    :param minimal:
        if True returns only chl_a_mean; drops the rest.
    :return:
        pandas datetime indexed dataframe
    """
    columns = ['time', 'nbins', 'mean', 'median', 'stdv']
    df = pd.read_csv(filepath, delim_whitespace=True, names=columns)
    df['datetime'] = df.time.apply(convert_secs2dt)
    df.set_index('datetime', inplace=True)
    if minimal:
        df = df[['mean']]
    df.rename(columns={'mean': 'chl_a_mean'}, inplace=True)
    return df


def get_monthly_means(df, **kwargs):
    """
    Groups data by month and compute annual cycle based on monthly means.
    :param df:
        datetime indexed pandas dataframe
    :param kwargs:
        year_start (optional): string, slice start
        year_end (optional): string, slice end
    :return:
        month-indexed pandas dataframe with monthly means
    """
    year_start = kwargs.pop('year_start', df.index.year[0])
    year_end = kwargs.pop('year_end', df.index.year[-1])
    return df.loc[str(year_start): str(year_end)].groupby(lambda x: x.month).aggregate('mean')


def get_anomaly(df, df_ann_cycle, name='chl_a_mean'):
    """
    Computes annomaly by removing monthly mean for a given month
    :param df:
        pandas dataframe with [name] parameter column
    :param df_ann_cycle:
        pandas dataframe of length 12 containing monthly means
    :param name:
        str, label of quantity to get anomaly from
    :return:
        None
    """

    for month in df_ann_cycle.index:
        idx = df.index.month == month
        df.loc[idx, 'chl_anomaly'] = df.loc[idx, name] - df_ann_cycle.loc[month, name]
        df.loc[idx, 'perc_chl_anom'] = df.loc[idx, 'chl_anomaly'] / df_ann_cycle.loc[month, name] * 100


