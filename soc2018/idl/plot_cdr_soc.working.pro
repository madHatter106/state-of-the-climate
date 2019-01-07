pro plot_cdr_soc, prod, region, tids, range=range, tdirs=tdirs, title=title, odir=odir, anomaly=anomaly, years=years, width=width, mei=mei

root  = getenv('TESTROOT')

nsens = n_elements(tids)

if (n_elements(tdirs  ) eq 0    ) then tdirs   = tids+'_'+tids
if (n_elements(years)   ne 2    ) then years   = [0,9999]
if (n_elements(width)   eq 0    ) then width  = 0

nsens = n_elements(tids)
fid   = '' & for isens=0,nsens-1 do fid = fid+tids[isens]+'_'
color = fsc_color(['black','blue','red','brown','orange'])

r = ocprod_info(prod)

      ; 
      ; read all once to get range
      ;
      data = get_data(tids[0],region,prod=prod,tdir=tdirs[0])
      time = data.time
      for isens=1,nsens-1 do begin
        data = [data,get_data(tids[isens],region,prod=prod,tdir=tdirs[isens])]
      endfor
      data = data[sort(data.time)]
      doy  = secs2doy(data.time,y)
      s = where(y ge years[0] and y le years[1])
      data = data[s]
      mean = avg(data.mean)
      time = data.time
      data_mean = mean

      if (keyword_set(anomaly)) then begin
        ytitle = 'Chla Anomaly (mg m!e-3!n)'
      endif else begin
        ytitle = 'Chla (mg m!e-3!n)'
      endelse

      jsplot,time,time*0.0,format='n$ @ Y$',xticks=4,color=fsc_color('Black'),background=fsc_color('White'),off=offset, $
          /nodata,yrange=range,ytitle=ytitle,xticklabelstep=2

      for isens=0,nsens-1 do begin

        tid  = tids [isens]
        tdir = tdirs[isens]
        data = get_data(tid,region,prod=prod,tdir=tdir)
        doy  = secs2doy(data.time,y)
        s = where(y ge years[0] and y le years[1])
        data = data[s]
        doy  = doy[s]

        if (max(data.mean) gt 0.0) then begin
          if (keyword_set(anomaly)) then begin
            if (strmid(tid,0,1) eq 'v') then begin
              data2 = get_data('ar2013.1m',region,prod=prod,tdir='ar2013.1m_ar2013.1m')
              doy2  = secs2doy(data2.time,y2)
              s = where(y2 ge 2003 and y2 le 2011)
              data2 = data2[s]
              c = avg_annual_cycle(data2)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
              data.mean = f
            endif else begin
              c = avg_annual_cycle(data)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
              data.mean = f
            endelse
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
          if (not keyword_set(anomaly)) then begin
              jsplot,time,time*0.0+mean,/over,color=fsc_color('black'),thick=2
          endif else begin
              jsplot,time,time*0.0,/over,color=fsc_color('black'),thick=2
          endelse
          if (isens eq 0) then data_all = data else data_all = [data_all,data]
        endif

      endfor

      if (keyword_set(anomaly)) then begin
        yr2=(!Y.CRANGE)/mean*100. 
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
              print,time[i],data_mean,(max(data_all[s].mean)-min(data_all[s].mean))/data_mean*100
              diff = diff + (max(data_all[s].mean)-min(data_all[s].mean))
              ndiff = ndiff + 1
            endif
          endif
        endfor

        diff = diff/ndiff

        s = where(numb gt 0)        
        x = time[s]
        y = smooth(mean[s],3)
        jsplot,x,y+diff,/over,color=fsc_color('grey')
        jsplot,x,y-diff,/over,color=fsc_color('grey')
        polyfill,[x[0],x,reverse(x)]-offset,[y[0]-diff,y+diff,reverse(y)-diff],color=fsc_color('Gray')
        cdr_time = time[s]
        cdr_mean = mean[s]
        print,'mean difference ',diff,data_mean,diff/data_mean*100.
      endif else $
        yr2=(!Y.CRANGE)/mean*100.-100.0

      for isens=0,nsens-1 do begin

        tid  = tids [isens]
        tdir = tdirs[isens]
        data = get_data(tid,region,prod=prod,tdir=tdir)
        doy  = secs2doy(data.time,y)
        s = where(y ge years[0] and y le years[1])
        data = data[s]
        doy  = doy[s]

        if (max(data.mean) gt 0.0) then begin
          if (keyword_set(anomaly)) then begin
            if (strmid(tid,0,1) eq 'v') then begin
              data2 = get_data('ar2013.1m',region,prod=prod,tdir='ar2013.1m_ar2013.1m')
              doy2  = secs2doy(data2.time,y2)
              s = where(y2 ge 2003 and y2 le 2011)
              data2 = data2[s]
              c = avg_annual_cycle(data2)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
              data.mean = f
            endif else begin
              c = avg_annual_cycle(data)
              f = data.mean - interpol(c[*,1],c[*,0],doy,/spline)
              data.mean = f
            endelse
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
          if (isens eq 0) then data_all = data else data_all = [data_all,data]
        endif

      endfor

      if (keyword_set(mei)) then begin
        indx = get_mei()
        indx_t = indx[*,0]-z2sec('2000001')
        indx_y = indx[*,1]*(!cymax-!cymin)/3/2/2*(-1)
        jsplot,indx_t,indx_y,/over,color=fsc_color('forest green'),psym=4,sy=0.4
        mei = spline(indx_t,indx_y,cdr_time)
        tstat = taylor_stats(mei,cdr_mean)
        print,'r ','r^2 ','t-value ','p-value '       
        print,region,tstat.r,(tstat.r)^2,tstat.t,tstat.p
     endif 

      if (keyword_set(anomaly)) then begin
        ytitle2 = 'Chla Anomaly (%)'
      endif else begin
        ytitle2 = 'Chla (%)'
      endelse
      axis, ya=1, yr=yr2, yst=1, yminor=2, YTITLE = ytitle2,color=fsc_color('black')

end

