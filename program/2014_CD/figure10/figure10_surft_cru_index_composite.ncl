;usage:  plot diff between negative and positive phase in landsea  index depended by cru index and make student t test
;Author  heyl
;date:  2012/12/2
;;rewrite on 20150825

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure10/"

fmy=addfile(pathin+"cru/cru_sst.nc","r")
time=fmy->time
yrstart=1948
yrlast=2008
yyyy=cd_calendar(time,-1)/100
iyyyy=ind(yyyy.ge.yrstart .and. yyyy .le. yrlast)
iyyyy=iyyyy+2
t=fmy->cru_sst(iyyyy,:,:)
t_DJF=month_to_season(t,"OND")
t_DJF@_FillValue=default_fillvalue("integer")
t_DJF&time=ispan(1948,2008,1)
t_DJF&lat@units="degrees_north"
t_DJF&lon@units="degrees_east"
printVarSummary(t_DJF)
t_DJF_ano=dim_rmvmean_n_Wrap(t_DJF,0)
;;;;;;year
year=ispan(1948,2008,1)
f=addfile(pathin+"cru/cru_index.nc","r")
cru_index=f->cru_index
positive=ind(dim_standardize(cru_index(0:60),0) .gt. 1)
negative=ind(dim_standardize(cru_index(0:60),0) .lt. -1)
positive_year=year(positive)
negative_year=year(negative)
;print(positive_year)
;print(negative_year)

positive_temp=dim_avg_n_Wrap(t_DJF_ano({time|positive_year},lat|:,lon|:),0)
negative_temp=dim_avg_n_Wrap(t_DJF_ano({time|negative_year},lat|:,lon|:),0)

diff=positive_temp-negative_temp
copyatt(diff,positive_temp)
printMinMax(positive_temp,True)
printMinMax(negative_temp,True)

varx=dim_variance_n_Wrap(t_DJF({time|positive_year},lat|:,lon|:),0)
vary=dim_variance_n_Wrap(t_DJF({time|negative_year},lat|:,lon|:),0)
sx=dimsizes(positive_year)
sy=dimsizes(negative_year)
s=sqrt((varx+vary)/(sx+sy-2))
s=where(s .eq. 0, default_fillvalue("integer"), s)
delete(t)
t=diff/s/sqrt(1.0/sx+1.0/sy)
t_diff=cdft_t(0.975,sx+sy-2)
mask_temp=mask(t,t .gt. -t_diff .and. t .lt. t_diff,False)
copyatt(mask_temp,positive_temp)
;mask_temp2=mask(prob,prob .lt. 0.01,True)
;copyatt(mask_temp2,prob)
;printVarSummary(diff)
;printVarSummary(mask_temp)
;printMinMax(diff,True)
;;composite, first choose negative positive year;;;;;;;;

;print(stopp)
;;;****************plot pacific and atlantic 
        wks             = gsn_open_wks("eps",pathout+"figure10_composite_surft_ce")
        ;gsn_define_colormap(wks,"GrayWhiteGray")
        gsn_define_colormap(wks,"BlueRed")

  res    = True
res@gsnDraw=False
res@gsnFrame=False
  res@cnFillOn  = True ;False
;cold_color=ispan(2,112,14)
;warm_color=ispan(128,238,11)
;res@cnFillColors=array_append_record(cold_color,warm_color,0)
res@gsnStringFontHeightF=0.02
res@tmXBLabelFontHeightF=0.018  ;used to ce plot
res@tmYLLabelFontHeightF=0.018
res@tiYAxisFontHeightF=0.02
res@tiXAxisFontHeightF=0.02
res@lbLabelFontHeightF=0.02
res@cnLineLabelFontHeightF=0.012
res@pmLabelBarOrthogonalPosF=0.25

  res@cnLinesOn  = True
  res@cnLineLabelsOn=True
 res@cnLineLabelPlacementMode="Constant"
  res@cnLineDashSegLenF          = 0.14          ; assist in controlling concentration
  res@cnLineLabelInterval        = 2             ; default = 2

res@cnFillColors=(/46,68,90,112,128,141,154,167,180,193,206,219,232/)
  res@cnLevelSelectionMode ="ManualLevels"
  res@cnMinLevelValF       =-1.50
  res@cnMaxLevelValF       =3.50
  res@cnLevelSpacingF      =0.50
res@mpMinLatF=0
res@mpMaxLatF=90
res@mpMinLonF=-180
res@mpMaxLonF=180

;res@vpXF=0.15
;res@vpYF=0.99
res@mpShapeMode = "FreeAspect"
res@vpWidthF=0.8
res@vpHeightF=0.3
;res@gsnMaximize=True
  res@gsnContourNegLineDashPattern =2
  res@gsnContourZeroLineThicknessF =2
res@gsnLeftString="(a)"
res@gsnRightString=""
res@gsnCenterString=""

plot=new(2,graphic)
plot(0)=gsn_csm_contour_map_ce(wks,positive_temp,res)
res@gsnLeftString="(b)"
  res@cnMinLevelValF       =-4.0
  res@cnMaxLevelValF       =2.0
  res@cnLevelSpacingF      =0.50
;res@vpXF=0.2
;res@vpYF=0.45
delete(res@cnFillColors)
res@cnFillColors=(/30,40,50,60,70,80,90,100,110,128,141,154,167,180,193,206,219,232/)
plot(1)=gsn_csm_contour_map_ce(wks,negative_temp,res)
gsn_panel(wks,plot,(/2,1/),True)
end
