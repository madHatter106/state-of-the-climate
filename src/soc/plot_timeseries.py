import matplotlib.pyplot as pl
from matplotlib import rcParams

plot_colors = {'swf': '#000000',
               'aqua': '#348ABD',
               'viirs': '#A60628',
               'mei': '#467821',
               }
rcParams['axes.labelsize'] = 14
rcParams['xtick.labelsize'] = 14
rcParams['ytick.labelsize'] = 14
rcParams['font.size'] = 14


def plot_single_timeseries(df, label='chl_anomaly', sensor='swf', ax=None):
    """

    :param df:
        pandas dataframe, timeseries
    :param label:
        str, column label in df
    :param sensor:
        str, sensor_name
    :param ax:
    :return:
    """
    if not ax:
        _, ax = pl.subplots(figsize=(17, 6))
    ax.plot(df.index.to_pydatetime(), df[label], marker='+', color=plot_colors[sensor])
    pl.draw_all()


def plot_all_time_series(df_dict, labels, figure_size=(17, 6), savefig=False):
    """

    :param df_dict:
        dictionary of dataframe keyed by sensor name.
        e.g. {'swf': df_swf, 'aqua': df_aqua}. The key will be used to populate the plot legend.
    :param labels:
        list
            contains column labels available in all dataframes provided in df_dict.
    :param figure_size:
        tuple
            size (LxH) of figure in inches.
    :param savefig:
        False [default] or str with path where figure is to be saved.
    """
    # TODO add datetime minorticks - quarters if possible, months otherwise.
    # TODO add Chla Anomaly (%) on right y-axis of anomaly plot.
    if not isinstance(df_dict, dict):
        raise TypeError
        print("df_dict must a dictionary")
    if not isinstance(labels, list):
        raise TypeError
        print("labels must be a list")
    f, ax = pl.subplots(nrows=len(labels), figsize=figure_size)
    for i, label in enumerate(labels):
        for sensor_i, df_i in df_dict.items():
            plot_single_timeseries(df_i, label=label, sensor=sensor_i, ax=ax)
    if savefig:
        f.savefigure(f, dpi=300, format='png')