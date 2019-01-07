; -----------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------
function get_data,tid,region,data1,data2,prod=prod,tdir=tdir,bias=bias

root   = getenv('TESTROOT')

if (n_elements(tdir) eq 0) then tdir  = tid
if (n_elements(prod) ne 0) then prods = [prod]
if (n_elements(bias) eq 0) then bias = 0.0

n = strlen(tid)
p = strpos(tid,'_',0)

;dirn   = root+'/l3stats/'+tdir
;dirn   = '/glusteruser/franz/soc/soc2016/TIMESERIES/'+tdir
dirn   = '/glusteruser/franz/soc/soc2017/TIMESERIES/'+tdir

data = read_trend_stats(dirn+'/stats',tid,region,prods)
data.mean = data.mean - bias

return,data
end

; -----------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------
pro plot_cdr_soc_npp, prod, region, tids, range=range, tdirs=tdirs, title=title, odir=odir, anomaly=anomaly, years=years, clim_years=clim_years,width=width, mei=mei, bias=bias

root  = getenv('TESTROOT')

nsens = n_elements(tids)

if (n_elements(tdirs  ) eq 0    ) then tdirs   = tids+'_'+tids   ; test directories for stats
if (n_elements(years)   ne 2    ) then years   = [0,9999]        ; year range for plots
if (n_elements(width)   eq 0    ) then width  = 0                ; boxcar smoothing 
if (n_elements(clim_years) ne 2 ) then clim_years = [2003,2011]  ; years to use for climatology

nsens = n_elements(tids)
color = fsc_color(['black','blue','red','brown','orange'])
r = ocprod_info(prod)

if (n_elements(bias) ne nsens) then bias = fltarr(nsens)

; 
; read all once to get time range and overall average
;
data = get_data(tids[0],region,prod=prod,tdir=tdirs[0],bias=bias[0])
time = data.time
for isens=1,nsens-1 do begin
    data = [data,get_data(tids[isens],region,prod=prod,tdir=tdirs[isens],bias=bias[isens])]
endfor
data = data[sort(data.time)]
doy  = secs2doy(data.time,y)
s = where(y ge years[0] and y le years[1])
data = data[s]
data_time = data.time
data_mean = avg(data.mean)
print,'mean value=',data_mean

;
; make empty plot with desired range and axis labeling
;
if (keyword_set(anomaly)) then begin
    ytitle = 'NPP (mg C m!e-2!n day!e-1!n)!C'
endif else begin
    ytitle = 'NPP (mg C m!e-2!n day!e-1!n)!C'    ; note the !C is a carriage return that moves the label over
endelse

jsplot,data_time,data_time*0.0,format='n$ @ Y$',xticks=4,color=fsc_color('Black'),background=fsc_color('White'),off=offset, $
      /nodata,yrange=range,ytitle=ytitle,xticklabelstep=4

;
; get sensor time-series (mean or anomaly)
;
for isens=0,nsens-1 do begin

    tid  = tids [isens]
    tdir = tdirs[isens]
    data = get_data(tid,region,prod=prod,tdir=tdir,bias=bias[isens])
    doy  = secs2doy(data.time,y)

    if (max(data.mean) gt 0.0) then begin

        if (keyword_set(anomaly)) then begin
;            if (strmid(tid,0,1) eq 'v') then begin
              ; for MODISA and VIIRS use MODISA 10-year mean
              data2 = get_data('ar2018.0m',region,prod=prod,tdir='ar2018.0m_ar2018.0m')
;              data2 = get_data('sr2014.0m',region,prod=prod,tdir='sr2014.0m_sr2014.0m')
              c = avg_annual_cycle(data2,yrange=clim_years)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
;            endif else begin
;              c = avg_annual_cycle(data,yrange=clim_years)
;              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
;            endelse
        endif else begin
            f = data.mean
        endelse 

        ;
        ; store a data time-series with anomalies replacing the means
        ; for later use in drawing error polygon
        ;
        data.mean = f
        if (isens eq 0) then data_all = data else data_all = [data_all,data]

    endif

endfor

;
; draw error polygon (average max-min differences in 30-day windows with more than one sensor reporting)
;
if (keyword_set(anomaly)) then begin
    
    doy = secs2doy(data_all.time,y)
    s = where(y ge years[0] and y le years[1])
    data_all = data_all[s]
    doy  = doy[s]
    ;
    ; bin data into 30-day increments and sum diffs
    ;
    t1 = min(data_all.time)
    t2 = max(data_all.time)
    dt = 86400*30
    ot = 86400*30
    nt = (t2-t1)/ot+1
    time = dblarr(nt)
    mean = fltarr(nt)
    stdv = fltarr(nt)
    numb = intarr(nt)
    diff = 0
    ndiff = 0
    for i=0,nt-1 do begin
        s = where(data_all.time ge t1-dt/2+ot*i and data_all.time le t1+dt/2+ot*i,ns)
        if (ns gt 0.0) then begin
            time[i] = avg(data_all[s].time)
            mean[i] = avg(data_all[s].mean)
            stdv[i] = stdev(data_all[s].mean)
            numb[i] = ns
            if (ns ge 2) then begin
              ;print,time[i],data_mean,(max(data_all[s].mean)-min(data_all[s].mean))/data_mean*100
              ; note: assumes mean IS the anomaly
              diff = diff + (max(data_all[s].mean)-min(data_all[s].mean))
              ndiff = ndiff + 1
            endif
        endif
    endfor
    diff = diff/ndiff

    ;
    ; plot polygon (mean +/- average diff)
    ;
    s = where(numb gt 0)        
    x = time[s]
    y = smooth(mean[s],3)
    polyfill,[x[0],x,reverse(x)]-offset,[y[0]-diff,y+diff,reverse(y)-diff],color=fsc_color('Gray')

endif

;
; now, repeat the time-series plot, as I can't figure-out how to make the polygon transparent
; 
for isens=0,nsens-1 do begin

    tid  = tids [isens]
    tdir = tdirs[isens]
    data = get_data(tid,region,prod=prod,tdir=tdir,bias=bias[isens])
    doy  = secs2doy(data.time,y)

    if (max(data.mean) gt 0.0) then begin
        if (keyword_set(anomaly)) then begin
;            if (strmid(tid,0,1) eq 'v') then begin
              ; for MODISA and VIIRS use MODISA 10-year mean
              data2 = get_data('ar2018.0m',region,prod=prod,tdir='ar2018.0m_ar2018.0m')
;              data2 = get_data('sr2014.0m',region,prod=prod,tdir='sr2014.0m_sr2014.0m')
              c = avg_annual_cycle(data2,yrange=clim_years)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
;            endif else begin
;              c = avg_annual_cycle(data,yrange=clim_years)
;              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
;            endelse
          endif else begin
            f = data.mean
          endelse 

          e = data.stdv/sqrt(data.nbins)
          if (width gt 1) then begin
              y = smooth(f,width)
          endif else begin
              y = f
          endelse

          jsplot,data.time,y,/over,color=color[isens]
          errplot,data.time-offset,y-e,y+e,color=color[isens]

      endif
endfor

;
; plot mei
;
if (keyword_set(mei)) then begin
    indx = get_mei()
    indx_t = indx[*,0]-z2sec('2000001')
    indx_y = indx[*,1]*(!cymax-!cymin)/10*(-1)  ; scale and invert 
    jsplot,indx_t,indx_y,/over,color=fsc_color('forest green'),psym=4,sy=0.6
    ;mei = spline(indx_t,indx_y,cdr_time)
    ;tstat = taylor_stats(mei,cdr_mean)
    ;print,'r ','r^2 ','t-value ','p-value '       
    ;print,region,tstat.r,(tstat.r)^2,tstat.t,tstat.p
endif 

;
; add horizontal line at global mean or zero
;
if (not keyword_set(anomaly)) then begin
    jsplot,data_time,data_time*0.0+data_mean,/over,color=fsc_color('black'),thick=2
endif else begin
    jsplot,data_time,data_time*0.0,/over,color=fsc_color('black'),thick=2
endelse

;
; add vertical lines for years
;
year_num  = (years[1]-years[0])/2+1
year_val  = string(years[0]/2*2+2+indgen(year_num)*2)
year_time = z2sec(year_val+'001')-z2sec('2000001')
for i=0,year_num-1 do begin
    jsplot,[year_time[i],year_time[i]],[!cymin,!cymax],/over,color=fsc_color('black'),thick=2,line=1
endfor

;
; draw right axis
;
if (keyword_set(anomaly)) then begin
    ytitle2 = 'NPP Anomaly (%)'
    yr2=(!Y.CRANGE)/data_mean*100. 
endif else begin
    ytitle2 = 'NPP (%)'
    yr2=(!Y.CRANGE)/data_mean*100.-100.0
endelse
axis, ya=1, yr=yr2, yst=1, yminor=2, YTITLE = ytitle2,color=fsc_color('black')

end

