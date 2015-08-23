load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
begin
f=addfile("/home/cheng/heyl/sst/sst.nc","r")
sst=f->sst(0:1307,:,:)  ;1901-2009 1308 months
a=addfile("/home/cheng/heyl/cru_low.nc","r")
lat=a->lat
lon=a->lon
lat=fspan(89.5,-89.5,180)
time=a->time
cru=a->cru

;printVarSummary(cru)

  ;     double cru ( time, lat, lon )
  ;      long_name :	near-surface temperature
  ;       units :	degrees Celsius
  ;       correlation_decay_distance :	1200
  ;       _FillValue :	9.969209968386869e+36
  ;       missing_value :	9.969209968386869e+36
sst@long_name="sst"
sst@units="degree Celsius"
sst@_FillValue=-9999
sst@missing_value=-9999
sst&time=(/dble2flt(time)/)
;printVarSummary(sst&time)
printVarSummary(sst)
system("/bin/rm -f  /home/cheng/heyl/sst/convert_sst.nc")
fout=addfile("/home/cheng/heyl/sst/convert_sst.nc","c")
fout->lon=lon
fout->lat=lat
;printVarSummary(time)
fout->time=time
fout->sst=sst
end
