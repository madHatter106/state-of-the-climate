year = '2017'

sensor    = ['modisa','modisa']
prods     = ['sst','chlor_a']
file      = ['MODISA/A'+year+'*MO_SST_sst.nc', 'MODISA/A'+year+'*MO_CHL_chlor_a.nc', 'VIIRSN/V'+year+'*MO_SNPP_CHL_chlor_a.nc']
form      = ['ncdf','ncdf']

clim_file = ['MODISA/A*MC_SST_sst.nc','MODISA/A*MC_CHL_chlor_a.nc']
clim_form = ['ncdf','ncdf']
clim_prod = ['sst','chlor_a']

suff = ['_mc','_mc']

nx = 4320
ny = 2160

for isen=0,n_elements(file)-1 do begin

  sens = sensor[isen]
  
  if (strpos(prods[isen],'sst') eq 0) then prod='sst' else prod='chl' 
  if (strpos(prods[isen],'sst') eq 0) then scale=0.005 else scale=1.0

  f1 = findfile(clim_file[isen])
  p1 = strpos(clim_file[isen],'/')
  day = strmid(f1,p1+6,3)
  s = sort(day)
  f1 = f1[s]

  f2 = findfile(file[isen])
  p2 = strpos(file[isen],'/')
  day = strmid(f2,p2+6,3)
  s = sort(day)
  f2 = f2[s]

  np = 12
  if (n_elements(f1) ne np or n_elements(f2) ne np) then begin
      print,'file count mismatch'
      stop
  endif

  for i=0,np-1 do print,i,'  ',f1[i],'  ',f2[i]

  pdiff = fltarr(nx,ny,np)
  diff = fltarr(nx,ny,np)
  print,nx,ny

  for i=0,np-1 do begin

    print,f1[i]
    if (clim_form[isen] eq 'hdf') then begin
        m1 = rd_sds(f1[i],'l3m_data')*scale
    endif else begin
        m1 = rd_ncdfvar(f1[i],clim_prod[isen])*scale
    endelse

    print,f2[i]
    if (form[isen] eq 'hdf') then begin
        m2 = rd_sds(f2[i],'l3m_data')*scale
    endif else begin
        m2 = rd_ncdfvar(f2[i],prods[isen])*scale
    endelse

    print,min(m1),max(m1),min(m2),max(m2)

    s = where(m1 gt -100 and m2 gt -100)
    d = m1 * 0.0 - 32767
    p = m1 * 0.0 - 32767
    d[s] = m2[s] - m1[s]
    p[s] = d[s]/(m1[s])*100
    diff[*,*,i] = d
    pdiff[*,*,i] = p

  endfor

  tdiff  = fltarr(nx,ny)
  tpdiff = fltarr(nx,ny)

  for i=0,nx-1 do for j=0,ny-1 do begin
    d = reform( diff[i,j,*])
    p = reform(pdiff[i,j,*])
    s = where(d gt -32766,ns)
    if (ns gt 2) then begin
        tdiff [i,j] = total(d[s])/ns
        tpdiff[i,j] = total(p[s])/ns
    endif else begin
        tdiff [i,j] = -32767
        tpdiff[i,j] = -32767
    endelse
  endfor

  deep = vflip(get_global_masks_mapped('deep'))
  s = where(deep eq 0)
  tdiff[s] = -32767
  tpdiff[s] = -32767

  ofile = sens+'_'+prod+'_diff_'+year+suff[isen]+'.dat'

  if (prod eq 'chl') then begin
    openw,1,ofile
    writeu,1,tpdiff
    close,1
  endif else begin
    openw,1,ofile
    writeu,1,tdiff
    close,1
  endelse

endfor

end
