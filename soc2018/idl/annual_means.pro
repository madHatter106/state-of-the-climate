pro annual_means, prod, region, tids, tdirs=tdirs, title=title, anomaly=anomaly, years=years, clim_years=clim_years

root  = getenv('TESTROOT')

nsens = n_elements(tids)

if (n_elements(tdirs  ) eq 0    ) then tdirs   = tids+'_'+tids   ; test directories for stats
if (n_elements(years)   ne 2    ) then years   = [0,9999]        ; year range for plots
if (n_elements(clim_years) ne 2 ) then clim_years = [2003,2011]  ; years to use for climatology

nsens = n_elements(tids)

for isens=0,nsens-1 do begin

    tid  = tids [isens]
    tdir = tdirs[isens]
    data = get_data(tid,region,prod=prod,tdir=tdir)
    doy  = secs2doy(data.time,y)

    if (max(data.mean) gt 0.0) then begin

        if (keyword_set(anomaly)) then begin
            if (strmid(tid,0,1) eq 'v') then begin
              ; for MODISA and VIIRS use MODISA 10-year mean
              data2 = get_data('ar2013.1m',region,prod=prod,tdir='ar2013.1m_ar2013.1m')
              c = avg_annual_cycle(data2,yrange=clim_years)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
            endif else begin
              c = avg_annual_cycle(data,yrange=clim_years)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
            endelse
        endif else begin
            f = data.mean
        endelse 

        for yr=years[0],years[1] do begin
            s = where(y ge yr and y lt yr+1,ns)
            if (ns gt 0) then begin
                mean = avg(f[s])
                print,tid,yr,ns,mean
             endif
        endfor

    endif

 endfor

end


years=[1997,2014]
clim_years = [2003,2011]
tdirs=['sr2010.0m_sr2010.0m','ar2013.1m_ar2013.1m','vr2014.0m_vr2014.0m']

annual_means,'chlor_a','eqsst',['sr2010.0m','ar2013.1m','vr2014.0m'],tdirs=tdirs,years=years,clim_years=clim_years
annual_means,'chlor_a','eqsst',['sr2010.0m','ar2013.1m','vr2014.0m'],tdirs=tdirs,years=years,clim_years=clim_years,/anomaly

end

