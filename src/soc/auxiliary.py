def get_string(res, return_str=True):
    res_str_list = [dt.strptime(resi, '%Y%j').strftime('%b-%d-%Y') for resi in res]
    if return_str:
        return f'{res_str_list[0]} - {res_str_list[1]}'
    else:
        return res_str_list


def build_dicts(mc_dict, mo_dict, mc_list, mo_list, verbose=True):
    v_date_pat = re.compile(r'V?(\d{7})')
    a_date_pat = re.compile(r'A?(\d{7})')
    for fv,fa in zip(mo_list, mc_list):
        v_dates = v_date_pat.findall(fv.as_posix())
        a_dates = a_date_pat.findall(fa.as_posix())
        v_date_rng_str = get_string(v_dates)
        a_date_rng_str = get_string(a_dates)
        mo_dict[v_date_rng_str[:3]] = fv
        mc_dict[a_date_rng_str[:3]] = fa
        if verbose:
            print(f'MO: {v_date_rng_str} => {fv.as_posix()}')
            print(f'MC: {a_date_rng_str} => {fa.as_posix()}')
            print('-'*80)
