load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;-----------------use cru_low.nc 360*180 
;   setfileoption("nc","Format","LargeFile")
b=addfile("/home/cheng/heyl/cru/cru_1901_2011.nc","r")
cru=b->cru
time=b->time
lon=b->lon
lat=b->lat
printVarSummary(cru)
printVarSummary(lat)
printVarSummary(lon)

;======================exist missing value   not succeed=========
;;;use area_conserve_remap_Wrap to regridding from 720*360 to 360*180 
;lat=latGlobeFo(360,"lat","latitude","degrees_north")
;lon=lonGlobeFo(720,"lon","longitude","degrees_north")


lat2=latGlobeFo(180,"lat","latitude","degrees_north")
lon2=lonGlobeFo(360,"lon","longitude","degrees_east")
lon2=lon2-180.0
printVarSummary(lat2)
printVarSummary(lon2)

;cru_low=area_conserve_remap_Wrap(lon,lat,cru,lon2,lat2,False)

cru_low=linint2_Wrap(lon,lat,cru,True,lon2,lat2,0)
cru_low@_FillValue=cru@_FillValue
cru_low@missing_value=cru@missing_value
cru_low@units=cru@units
printVarSummary(cru_low)
;============================
;Number Of Attributes: 5
;  long_name :	near-surface temperature
;  units :	degrees Celsius
;  correlation_decay_distance :	1200
;  _FillValue :	9.969209968386869e+36
;  missing_value :	9.969209968386869e+36

printMinMax(cru_low,True)
printMinMax(cru,True)


system("/bin/rm -f /home/cheng/heyl/cru/cru_low.nc")
fout=addfile("/home/cheng/heyl/cru/cru_low.nc","c")
fout->lon=lon2
fout->lat=lat2
fout->time=time
fout->cru=cru_low

end
