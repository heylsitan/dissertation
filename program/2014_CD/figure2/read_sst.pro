;;read sst output formated array sst from  1901 to 2010,but 2011 data has some question,will be added in later 
;sst=make_array(360,180,12,106,/float);lon,lat,month,year
ct_year=2010-1901+1
sst=fltarr(360,180,12,110)
openr,lun0,'/home/cheng/heyl/sst/HadISST1_SST_1901-1930.txt',/get_lun	
openr,lun1,'/home/cheng/heyl/sst/HadISST1_SST_1931-1960.txt',/get_lun
openr,lun2,'/home/cheng/heyl/sst/HadISST1_SST_1961-1990.txt',/get_lun
openr,lun3,'/home/cheng/heyl/sst/HadISST1_SST_1991-2003.txt',/get_lun
openr,lun4,'/home/cheng/heyl/sst/HadISST1_SST_2004.txt',/get_lun
openr,lun5,'/home/cheng/heyl/sst/HadISST1_SST_2005.txt',/get_lun
openr,lun6,'/home/cheng/heyl/sst/HadISST1_SST_2006.txt',/get_lun
openr,lun7,'/home/cheng/heyl/sst/HadISST1_SST_2007.txt',/get_lun
openr,lun8,'/home/cheng/heyl/sst/HadISST1_SST_2008.txt',/get_lun
openr,lun9,'/home/cheng/heyl/sst/HadISST1_SST_2009.txt',/get_lun
openr,lun10,'/home/cheng/heyl/sst/HadISST1_SST_2010.txt',/get_lun
header=make_array(1,/string)
data=intarr(360,180)

for year=1901,1930 do begin
for month=0,11 do begin
readf,lun0,header
readf,lun0,data,format='(360I6)'
sst[*,*,month,year-1901]=data
endfor
endfor
for year=1931,1960 do begin
for month=0,11 do begin
readf,lun1,header
readf,lun1,data,format='(360I6)'
sst[*,*,month,year-1901]=data
endfor
endfor
for year=1961,1990 do begin
for month=0,11 do begin
readf,lun2,header
readf,lun2,data,format='(360I6)'
sst[*,*,month,year-1901]=data
endfor
endfor
for year=1991,2003 do begin
for month=0,11 do begin
readf,lun3,header
readf,lun3,data,format='(360I6)'
sst[*,*,month,year-1901]=data
endfor
endfor
;;;;;;;;2004
for month=0,11 do begin
readf,lun4,header
readf,lun4,data,format='(360I6)'
sst[*,*,month,2004-1901]=data
endfor
;;;;;;2005
for month=0,11 do begin
readf,lun5,header
readf,lun5,data,format='(360I6)'
sst[*,*,month,2005-1901]=data
endfor
;;;;2006
for month=0,11 do begin
readf,lun6,header
readf,lun6,data,format='(360I6)'
sst[*,*,month,2006-1901]=data
endfor
;;;;2007
for month=0,11 do begin
readf,lun7,header
readf,lun7,data,format='(360I6)'
sst[*,*,month,2007-1901]=data
endfor
;;;;2008
for month=0,11 do begin
readf,lun8,header
readf,lun8,data,format='(360I6)'
sst[*,*,month,2008-1901]=data
endfor
;;;;2009
for month=0,11 do begin
readf,lun9,header
readf,lun9,data,format='(360I6)'
sst[*,*,month,2009-1901]=data
endfor
;;;;2010
for month=0,11 do begin
readf,lun10,header
readf,lun10,data,format='(360I6)'
sst[*,*,month,2010-1901]=data
endfor
free_lun,lun0
free_lun,lun1
free_lun,lun2
free_lun,lun3
free_lun,lun4
free_lun,lun5
free_lun,lun6
free_lun,lun7
free_lun,lun8
free_lun,lun9
free_lun,lun10
index=where(sst eq -32768 or sst eq -1000 )
sst[index]=!values.F_NAN
sst=sst/100.0
sst[index]=-9999

lat=89.5-indgen(180)
lon=indgen(360)-179.5
time=indgen(110*12)
sst=reform(sst,360,180,12*110)
fid=ncdf_create('/home/cheng/heyl/sst/sst.nc',/clobber)
dimx=ncdf_dimdef(fid,'lon',360)
dimy=ncdf_dimdef(fid,'lat',180)
dimz=ncdf_dimdef(fid,'time',12*110)
vid1=ncdf_vardef(fid,'lon',[dimx],/float)
vid2=ncdf_vardef(fid,'lat',[dimy],/float)
vid3=ncdf_vardef(fid,'time',[dimz],/float)
vid4=ncdf_vardef(fid,'sst',[dimx,dimy,dimz],/float)

ncdf_attput,fid,vid1,'long_name','longtitude'
ncdf_attput,fid,vid1,'units','degrees_east'

ncdf_attput,fid,vid2,'long_name','latitude'
ncdf_attput,fid,vid2,'units','degrees_north'

ncdf_attput,fid,vid3,'long_name','year-month'

ncdf_attput,fid,vid4,'long_name','sst'
;ncdf_attput,fid,vid4,'_FillValue','-9999'

ncdf_control,fid,/endef
ncdf_varput,fid,vid1,lon
ncdf_varput,fid,vid2,lat
ncdf_varput,fid,vid3,time
ncdf_varput,fid,vid4,sst

ncdf_close,fid
end



