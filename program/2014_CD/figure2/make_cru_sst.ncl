load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
a=addfile("/home/cheng/heyl/sst/convert_sst.nc","r")
sst=a->sst;(0:1307,:,:) 1901-2011
lat=a->lat
lon=a->lon
printVarSummary(lat)
printVarSummary(lon)
printVarSummary(sst)
;print(a->lat)
b=addfile("/home/cheng/heyl/cru/cru_low.nc","r")
cru=b->cru
time=b->time
;cru!0="time"
;cru!1="lat"
;cru!2="lon"
;cru&time=time
;cru&lat=-lat
;cru&lon=lon

cru=cru(:,::-1,:)  ; cru -89.5 .. 89.5 need reversed
;print("ok")
printVarSummary(cru)
;print("ok")
                 ; land-sea mask distributed with NCL
fmsk    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   
lsmask  = landsea_mask(fmsk->LSMASK,lat,lon)  
lsmask2  = conform(cru,lsmask,(/1,2/))
cru_sst=sst
print("ok")
cru_sst = where(lsmask2.eq.1,dble2flt(cru),sst)  ;
print("ok")
cru_sst&time=(/time/)
;cru_sst!0="lat"
;cru_sst!1="lon"
;cru_sst&lat=lat
;cru_sst&lon=lon
 
printVarSummary(cru_sst)
;printVarSummary(time)
system("/bin/rm -f /home/cheng/heyl/cru/cru_sst.nc")
fout=addfile("/home/cheng/heyl/cru/cru_sst.nc","c")
fout->lon=lon
fout->lat=lat
fout->time=time
fout->cru_sst=cru_sst
end
;T=cru(0,:,:)
;T1=sst(0,:,:)
;T2=cru_sst

;printVarSummary(T2)
;printVarSummary(cru_sst)

;***************************************
; create individual plots
;***************************************
;  wks = gsn_open_wks("ps" ,"test_cru_sst")               ; open ps file
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")  ; choose colormap
;  plot=new(3,graphic)
;  res                      = True               ; plot mods desired
;  res@cnFillOn             = True               ; color contours
;  res@cnLinesOn            = False              ; default is True
;  res@cnLineLabelsOn       = False              ; default is True
;  res@gsnMaximize          = True               ; make ps, pdf, eps large
;
;;---This resource not needed in NCL V6.1.0
;  res@gsnSpreadColors      = True               ; use full range of colormap
;
;  res@gsnCenterString      = "test cru_sst"
;  res@tiMainString         = "January: 1901"
;  plot(0)  = gsn_csm_contour_map_ce(wks,T,res)
;  plot(1)  = gsn_csm_contour_map_ce(wks,T1,res)
;  plot(2)  = gsn_csm_contour_map_ce(wks,T2,res)
;  gsn_panel(wks,plot,(/3,1/),False)
;

;end
;-----------------use cru_low.nc 360*180 
;b=addfile("/home/cheng/heyl/cru_ts_3_10.1901.2009.tmp.dat.nc","r")
;cru=b->tmp
;time=b->time
;lon=b->lon
;lat=b->lat
;printVarSummary(cru)

;======================exist missing value   not succeed=========
;;;use area_conserve_remap_Wrap to regridding from 720*360 to 360*180 
;lat=latGlobeFo(360,"lat","latitude","degrees_north")
;lon=lonGlobeFo(720,"lon","longitude","degrees_north")
;lat2=latGlobeFo(180,"la2t","latitude2","degrees_north")
;lon2=lonGlobeFo(360,"lon2","longitude2","degrees_north")
;;cru_low=area_conserve_remap_Wrap(lon,lat,cru,lon2,lat2,False)
;cru_low=linint2_Wrap(lon,lat,cru,True,lon2,lat2,0)
;============================

;printMinMax(cru_low,True)
;printMinMax(cru,True)


;system("/bin/rm -f /home/cheng/heyl/cru_low.nc")
;fout=addfile("/home/cheng/heyl/cru_low.nc","c")
;fout->lon=lon2
;fout->lat=lat2
;fout->time=time
;fout->cru=cru_low
;end
