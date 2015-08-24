;;usage: based on cru index choose landsea thermal contrast high year and low year
;;      to invesgate the geopotential height change and slp change
;;Author: heyl 12/1/2012
;;note: make t test, ouput picture change geopotential height
;;      ncep epflux 1948-2010 63 winters
;;	myindex from cru_sst only 1901-2009  so time 1948-2008 winter
;; output  polar 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"        ; functions required to
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"         ; plot.  include before
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"       ; begin

begin
pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure3/"

f=addfile(pathin+"cru/cru_index.nc","r")
cru_index=f->cru_index  ;1949-2011 winter
;printVarSummary(cru_index)
positive=ind(dim_standardize(cru_index,0) .gt. 1)
negative=ind(dim_standardize(cru_index,0) .lt. -1)
year=ispan(1949,2011,1)
positive_year=year(positive)
negative_year=year(negative)
print(positive_year)
print(negative_year)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ff     = addfile (pathin+"ncep/ncep_hgt_1948_2012.nc", "r")
  lat    = ff->lat
  lon    = ff->lon
  yrStrt = 1948
  yrLast = 2010
  TIME   = ff->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  iYYYY  = iYYYY+2
  hgt_tmp= ff->hgt(iYYYY,5,:,:)                      ;lev(5)=500hpa
  hgt_DJF= month_to_season(hgt_tmp,"OND")
  hgt_ano=dim_rmvmean_n(hgt_DJF,0)
  copyatt(hgt_ano,hgt_DJF)
  hgt    =hgt_ano;(lat|:,lon|:,time|:)               ;reorder in order to regcoef
  printVarSummary(hgt)                              ; variable overview
;print(hgt&time)
hgt&time=ispan(1949,2011,1)
hgt&lat@units="degrees_north"
hgt&lon@units="degrees_east"
positive_hgt=dim_avg_n_Wrap(hgt({time|positive_year},lat|:,lon|:),0)
negative_hgt=dim_avg_n_Wrap(hgt({time|negative_year},lat|:,lon|:),0)
diff_hgt=positive_hgt-negative_hgt
;;printVarSummary(positive_hgt&lat)
copyatt(diff_hgt,positive_hgt)
varx=dim_variance_n(hgt({time|positive_year},lat|:,lon|:),0)
vary=dim_variance_n(hgt({time|negative_year},lat|:,lon|:),0)
sx=dimsizes(positive_year)
sy=dimsizes(negative_year)
s=sqrt((varx+vary)/(sx+sy-2))
t=diff_hgt/s/sqrt(1.0/sx+1.0/sy)
t_hgt=cdft_t(0.975,sx+sy-2)
mask_hgt=mask(t,t .gt. -t_hgt .and. t .lt. t_hgt,False)
copyatt(mask_hgt,positive_hgt)
printMinMax(positive_hgt,True)
printMinMax(negative_hgt,True)
printMinMax(diff_hgt,True)

;****************************
;plot polar stereographic 
;****************************
wks=gsn_open_wks("eps",pathout+"figure3_hgt_composite")

gsn_define_colormap(wks,"BlueRed")

;gsn_define_colormap(wks,"rainbow")
  res    = True
res@gsnDraw=False
res@gsnFrame=False
  res@cnFillOn  = True ;False
;cold_color=ispan(2,112,14)
;warm_color=ispan(128,238,11)
;res@cnFillColors=array_append_record(cold_color,warm_color,0)
res@gsnStringFontHeightF=0.025
;res@tmXBLabelFontHeightF=0.04  ;used to ce plot
;res@tmYLLabelFontHeightF=0.04
res@gsnPolarLabelFontHeightF=0.018
res@gsnPolarLabelDistance    = 1.08     
res@tiYAxisFontHeightF=0.02
res@tiXAxisFontHeightF=0.02
res@lbLabelFontHeightF=0.02
res@cnLineLabelFontHeightF=0.022
;res@pmLabelBarOrthogonalPosF=0.4

  res@cnLinesOn  = True
  res@cnLineLabelsOn=True
 res@cnLineLabelPlacementMode="Constant"
  res@cnLineDashSegLenF          = 0.14          ; assist in controlling concentration
  res@cnLineLabelInterval        = 1             ; default = 2

  res@cnLevelSelectionMode ="ManualLevels"
  res@cnMinLevelValF       =-50.0
  res@cnMaxLevelValF       =50.0
  res@cnLevelSpacingF      =10.0
res@mpMinLatF=0
res@mpMaxLatF=90
;res@mpMinLonF=-180
;res@mpMaxLonF=180
res@gsnPolar="NH"

;res@vpXF=0.3
;res@vpYF=0.8
res@vpWidthF=0.4
res@vpHeightF=0.8
;res@gsnPolar="NH"
  res@gsnContourNegLineDashPattern =2
  res@gsnContourZeroLineThicknessF =2
res@gsnLeftString="(a)"
res@gsnRightString=""
res@gsnCenterString=""

plot=new(3,graphic)
plot(0)=gsn_csm_contour_map_polar(wks,positive_hgt,res)
res@gsnLeftString="(b)"
plot(1)=gsn_csm_contour_map_polar(wks,negative_hgt,res)
  res@cnMinLevelValF       =-100.0
  res@cnMaxLevelValF       =100.0
  res@cnLevelSpacingF      =20.0
res@gsnLeftString=""
res@cnLinesOn  = True
res@cnLineLabelsOn=True
res@cnInfoLabelOn=False
res@cnFillOn  = False
res@cnLineLabelFontHeightF=0.014
delete([/res@mpMinLatF,res@mpMaxLatF,res@gsnPolar,res@gsnPolarLabelFontHeightF,res@gsnPolarLabelDistance/])
plot0=gsn_csm_contour(wks,diff_hgt,res)
plres=True
plres@gsnDraw=False
plres@gsnFrame=False
plres@vpWidthF=0.4
plres@vpHeightF=0.8
plres@mpMinLatF=0
plres@mpMaxLatF=90
plres@gsnPolar="NH"

plres@cnMonoFillPattern=True
;plres@cnFillPattern=6

plres@cnLinesOn=False 
plres@cnFillOn=True
plres@lbLabelBarOn         = False    
plres@cnInfoLabelOn=False
plres@cnMonoFillColor=True
plres@cnFillColor=110;"black"
plres@gsnStringFontHeightF=0.025
plres@gsnPolarLabelFontHeightF=0.018
plres@gsnPolarLabelDistance    = 1.08
plres@gsnLeftString="(c)"
plres@gsnRightString=""
plres@gsnCenterString=""
;plres@tiMainString="surface temperate Diff(H-L)"
plot(2)=gsn_csm_contour_map_polar(wks,mask_hgt,plres)
overlay(plot(2),plot0)
resP=True
resP@gsnMaximize=True
gsn_panel(wks,plot,(/3,1/),resP)
end



