ofile = 'modisa_chl_sst_relation_2017_mc.dat'
chlfile = 'modisa_chl_diff_2017_mc.dat' 
 
;ofile = 'viirs_chl_sst_relation_2016_mc.dat'
;chlfile = 'viirs_chl_diff_2016_mc.dat'  ; viirs to MODIS clim  

;ofile = 'viirs_chl_sst_relation_2014_vc.dat'
;chlfile = 'viirs_chl_diff_2014_vc.dat'  ; viirs to VIIRS clim  

sstfile = 'modisa_sst_diff_2017_mc.dat'
sst_thresh = 0.1
chl_thresh = 5.0
sst_thresh = 0.1
chl_thresh = 3.0

nx = 4320
ny = 2160

chl = fltarr(nx,ny)
sst = fltarr(nx,ny)

openr,1,chlfile
readu,1,chl
close,1

openr,2,sstfile
readu,2,sst
close,2

diff = chl * 0.0 - 32767

s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh,npts)

s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and chl le 0.0 and sst ge 0.0,ns) & print,ns*100./npts
diff[s] = 1 ; red

s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and chl ge 0.0 and sst ge 0.0,ns) & print,ns*100./npts
diff[s] = 2 ; yellow

s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and chl le 0.0 and sst le 0.0,ns) & print,ns*100./npts
diff[s] = 3 ; green

s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and chl ge 0.0 and sst le 0.0,ns) & print,ns*100./npts
diff[s] = 4 ; blue

lat = findgen(2160)*0.08333 - 90.0 + 0.08333/2
lat = (fltarr(4320)+1) # lat
s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and abs(lat) le 40,npts)
s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and abs(lat) le 40 and chl le 0.0 and sst ge 0.0,ns) & print,ns*100./npts
s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and abs(lat) le 40 and chl ge 0.0 and sst ge 0.0,ns) & print,ns*100./npts
s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and abs(lat) le 40 and chl le 0.0 and sst le 0.0,ns) & print,ns*100./npts
s = where(chl gt -32766 and sst gt -32766 and abs(sst) gt sst_thresh and abs(chl) gt chl_thresh and abs(lat) le 40 and chl ge 0.0 and sst le 0.0,ns) & print,ns*100./npts

;s = where(chl gt -32766 and sst gt -32766)
;print,total(sst[s]*cos(lat[s]*!pi/180))/total(cos(lat[s]*!pi/180))
;print,total(chl[s]*cos(lat[s]*!pi/180))/total(cos(lat[s]*!pi/180))
;s = where(abs(lat) le 40 and chl gt -32766 and sst gt -32766)
;print,total(sst[s]*cos(lat[s]*!pi/180))/total(cos(lat[s]*!pi/180))
;print,total(chl[s]*cos(lat[s]*!pi/180))/total(cos(lat[s]*!pi/180))

openw,1,ofile
writeu,1,diff
close,1

end

