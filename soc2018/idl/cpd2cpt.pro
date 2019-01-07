@readcolnew

pro cpd2cpt, cpdfile, cptfile, range=range, num=num

readcol,cpdfile,line,format='a',delimiter=':'

s = where(strmid(line,0,5) eq 'color',ns)
p = where(strmid(line,0,6) eq 'sample',np)

color = intarr(3,ns)
sampl = fltarr(ns)
a = {x:intarr(3)}

for i=0,ns-1 do begin

  cline = strmid(line[s[i]],strpos(line[s[i]],'=')+1,30)
  sline = strmid(line[p[i]],strpos(line[p[i]],'=')+1,30)

  reads,cline,a

  color[*,i] = reform(a.x)
  sampl[i] = float(sline)

endfor

if (keyword_set(range)) then begin
    if (not keyword_set(num)) then num=ns
    if (n_elements(range) eq 2) then begin
        sampl = findgen(num)/(num-1)*(range[1]-range[0])+range[0]
    endif
endif

openw,1,cptfile
for i=0,ns-2 do begin
printf,1,sampl[i],color[0,i],color[1,i],color[2,i], $
      sampl[i+1],color[0,i+1],color[1,i+1],color[2,i+1], $
      format='(f,i,i,i,f,i,i,i)'
endfor
printf,1,'F 255 255 255'
printf,1,'B 0 0 0'
printf,1,'N 0 0 0'
close,1

end
