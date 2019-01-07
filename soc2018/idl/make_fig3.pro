@avg_annual_cycle.pro
@get_data.pro
@jsplot.pro
@plot_cdr_soc.pro

width=1
years=[1997,2019]
clim_years = [2003,2011]
;tdirs=['sr2014.0m_sr2014.0m','ar2014.0m_ar2014.0m','vr2014.0m_vr2014.0m']
tdirs=['sr2018.0m_sr2018.0m','ar2018.0m_ar2018.0m','vr2018.0m_vr2018.0m']
ofile = 'figure3.ps'

!p.multi = [0,1,2]
!p.charsize = 0.55
!p.thick = 2

sav_xmargin = !x.margin  &  !x.margin = [10,10]
sav_ymargin = !x.margin  &  !y.margin = [0,4]
sav_ystyle  = !y.style   &  !y.style  = 8
sav_font    = !p.font    &  !p.font   = 0

cgPS_Open,file=ofile,xsize=5,ysize=5,/inches,/nomatch

plot_cdr_soc,'chlor_a','eqsst',['sr2018.0m','ar2018.0m','vr2018.0m'],bias=[0.0,0.0,0.0],range=[0.1,0.2],tdirs=tdirs,years=years,width=width,clim_years=clim_years
plot_cdr_soc,'chlor_a','eqsst',['sr2018.0m','ar2018.0m','vr2018.0m'],bias=[0.0,0.0,0.0],range=[-0.04,0.04],tdirs=tdirs,years=years,width=width,clim_years=clim_years,/anomaly,/mei

;plot_cdr_soc_npp,'npp_vgpm','eqsst',['sr2018.0m','ar2018.0m','vr2018.0m'],bias=[0.0,0.0,0.0],range=[250,400],tdirs=tdirs,years=years,width=width,clim_years=clim_years
;plot_cdr_soc_npp,'npp_vgpm','eqsst',['sr2018.0m','ar2018.0m','vr2018.0m'],bias=[0.0,0.0,0.0],range=[-50.0,50.0],tdirs=tdirs,years=years,width=width,clim_years=clim_years,/anomaly,/mei

;plot_cdr_soc_npp,'npp_eppley','eqsst',['sr2018.0m','ar2018.0m','vr2018.0m'],bias=[0.0,0.0,0.0],range=[300,450],tdirs=tdirs,years=years,width=width,clim_years=clim_years
;plot_cdr_soc_npp,'npp_eppley','eqsst',['sr2018.0m','ar2018.0m','vr2018.0m'],bias=[0.0,0.0,0.0],range=[-50.0,50.0],tdirs=tdirs,years=years,width=width,clim_years=clim_years,/anomaly,/mei

;xyouts,0.2,0.83,'a.',/normal,color=fsc_color('black'),charsize=0.8
;xyouts,0.2,0.33,'b.',/normal,color=fsc_color('black'),charsize=0.8

xyouts,0.12,0.90,'a.',/normal,color=fsc_color('black'),charsize=0.8
xyouts,0.12,0.40,'b.',/normal,color=fsc_color('black'),charsize=0.8

cgPS_Close  ;,/pdf

print,ofile

spawn,'gmt psconvert -A -Tg '+ofile
spawn,'gmt psconvert -A -Tf '+ofile

!x.margin = sav_xmargin
!y.margin = sav_ymargin
!y.style  = sav_ystyle
!p.font   = sav_font

end
