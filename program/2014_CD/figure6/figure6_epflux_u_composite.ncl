;usage: based on cru_index choose landsea thermal contrast high year and low year
;;;      to invesgate the planetary wave intensity
;;;Author: heyl 12/1/2012
;;;note: make t test, ouput picture change div and fy fz seperate
;;;      ncep epflux 1948-2010 63 winters
;;;	myindex from cru_sst only 1901-2009  so time 1948-2008 winter
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"        ; functions required to
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"         ; plot.  include before
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"       ; begin

begin
pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure6/"

f=addfile(pathin+"cru/cru_index.nc","r")
cru_index=f->cru_index  ;1948-2011 winter
;printVarSummary(cru_index)
positive=ind(dim_standardize(cru_index,0) .gt. 1)
negative=ind(dim_standardize(cru_index,0) .lt. -1)
year=ispan(1949,2011,1)
positive_year=year(positive)
negative_year=year(negative)
print(positive_year)
print(negative_year)
;;;****************************u cross lev vs lat ***************************************
ufile=addfile(pathin+"epflux/uwnd.mon.mean.nc","r")
utime=ufile->time
uyyyy=cd_calendar(utime,-1)/100
yrstart=1948
yrlast=2010
uiyyyy=ind(uyyyy.ge.yrstart .and. uyyyy .le. yrlast)
uiyyyy=uiyyyy+2
;print(iyyyy)
u_tmp=ufile->uwnd(uiyyyy,:,:,:)
u=u_tmp*u_tmp@scale_factor+u_tmp@add_offset
copyatt(u,u_tmp)
;printMinMax(u,True)

uzm=dim_avg_Wrap(u)
;printVarSummary(uzm)
uzm_DJF=month_to_season(uzm,"OND")
uzm_DJF&time=ispan(1949,2011,1)
;printVarSummary(uzm_DJF)
positive_uzm=dim_avg_n_Wrap(uzm_DJF({time|positive_year},{level|1000:50},{lat|0:90}),0)
negative_uzm=dim_avg_n_Wrap(uzm_DJF({time|negative_year},{level|1000:50},{lat|0:90}),0)
diff_uzm=positive_uzm-negative_uzm
printMinMax(positive_uzm,True)
printMinMax(negative_uzm,True)
copyatt(diff_uzm,positive_uzm)
printVarSummary(diff_uzm)
printMinMax(diff_uzm,True)
varux=dim_variance_n(uzm_DJF({time|positive_year},{level|1000:50},{lat|0:90}),0)
varuy=dim_variance_n(uzm_DJF({time|negative_year},{level|1000:50},{lat|0:90}),0)
sx=dimsizes(positive_year)
sy=dimsizes(negative_year)
s=sqrt((varux+varuy)/(sx+sy-2))
t=diff_uzm/s/sqrt(1.0/sx+1.0/sy)
t_u=cdft_t(0.975,sx+sy-2)
mask_diff=mask(t,t .gt. -t_u .and. t .lt. t_u,False)
copyatt(mask_diff,positive_uzm)
mask_diff@_FillValues=default_fillvalue("float")

f2=addfile(pathin+"epflux/NCEP_EPDJF.nc","r")
EPdiv=f2->div
;Fz=f2->fz
;Fy=f2->fy   ;(year,wn,lev,lat) wn:0,1,2,3 0is all waves year:1949-2011
 positive_div = dim_avg_n_Wrap(EPdiv({year|positive_year},wn|0,{lev|1000:50},{lat|0:85}),0)
negative_div = dim_avg_n_Wrap(EPdiv({year|negative_year},wn|0,{lev|1000:50},{lat|0:85}),0)
diff_div=positive_div-negative_div
copyatt(diff_div,positive_div)
printMinMax(positive_div,True)
printMinMax(negative_div,True)
printMinMax(diff_div,True)
;;;***************************diff t test****************************
delete([/s,t/])
varx=dim_variance_n(EPdiv({year|positive_year},wn|0,{lev|1000:50},{lat|0:85}),0)
vary=dim_variance_n(EPdiv({year|negative_year},wn|0,{lev|1000:50},{lat|0:85}),0)
sx=dimsizes(positive_year)
sy=dimsizes(negative_year)
s=sqrt((varx+vary)/(sx+sy-2))
t=diff_div/s/sqrt(1.0/sx+1.0/sy)
t_div=cdft_t(0.975,sx+sy-2)
mask_div=mask(t,t .gt. -t_div .and. t .lt. t_div,False)
mask_div=smth9_Wrap(mask_div,0.5,0.25,False)
print(mask_div(0,0))
copyatt(mask_div,positive_div)
;**********************plot **********************************************************
wks=gsn_open_wks("eps",pathout+"figure6_composite_ep_u")
gsn_define_colormap(wks,"BlueRed");"GrayWhiteGray")
plot=new(6,graphic)
ures=True
ures@gsnDraw=False
ures@gsnFrame=False
  ures@cnLevelSelectionMode = "ManualLevels"       ; manually select levels
  ures@cnLevelSpacingF      = 5.0                  ; contour spacing
  ures@cnMinLevelValF       = -5.                 ; min level
  ures@cnMaxLevelValF       =  40.                 ; max level
  ures@cnLineLabelsOn       = True                 ; turn on line labels
  ures@cnLinesOn	    = True
  ures@cnFillOn             = True                 ; turn on color fill
  ures@tmYRMode   = "Automatic"          ; turn off special labels on right axis  
  ures@cnLineLabelPlacementMode="Constant"
  ures@cnLineDashSegLenF          = 0.14          ; assist in controlling concentration
  ures@cnLineLabelInterval        = 1             ; default = 2

  ures@vpWidthF=0.6
  ures@vpHeightF=0.6
  ures@gsnContourNegLineDashPattern =2
  ures@gsnContourZeroLineThicknessF =2

cold_color=(/30,60/)
warm_color=ispan(128,245,13)
ures@cnFillColors=array_append_record(cold_color,warm_color,0)

ures@tmXBLabelFontHeightF=0.025  ;used to ce plot
ures@tmYLLabelFontHeightF=0.025
ures@gsnLeftStringFontHeightF=0.03
ures@tiYAxisFontHeightF=0.03
ures@tiXAxisFontHeightF=0.025
ures@lbLabelFontHeightF=0.025
ures@cnLineLabelFontHeightF=0.022
  ures@gsnLeftString  = "(a)"
  ures@gsnRightString   = ""
  ures@gsnCenterString    = ""
plot(0)=gsn_csm_pres_hgt(wks,positive_uzm,ures)
  ures@gsnLeftString  = "(b)"
plot(2)=gsn_csm_pres_hgt(wks,negative_uzm,ures)
  ures@cnLevelSpacingF      = 1.0                  ; contour spacing
  ures@cnMinLevelValF       = -2.                 ; min level
  ures@cnMaxLevelValF       =  4.                 ; max level
  ures@gsnLeftString  = ""
  ures@cnLinesOn=True
  ures@cnLineLabelsOn=True
  ures@cnFillOn=False
  ures@cnInfoLabelOn=False
;  ures@cnLineLabelFontHeightF=0.014
plot0=gsn_csm_pres_hgt(wks,diff_uzm,ures)
plres=True
plres@gsnDraw=False
plres@gsnFrame=False
plres@vpWidthF=0.6
plres@vpHeightF=0.6
plres@cnMonoFillPattern=True
;plres@cnFillPattern=17;6
plres@cnInfoLabelOn=False
plres@cnMonoFillColor=True
plres@cnFillColor=110;"black"
plres@tmYRMode="Automatic"

plres@cnFillOn=True
plres@cnLinesOn= False 
plres@cnLineLabelsOn=False
plres@lbLabelBarOn         = False    
plres@gsnLeftString="(c)"
plres@gsnRightString=""
plres@tmXBLabelFontHeightF=0.025  ;used to ce plot
plres@tmYLLabelFontHeightF=0.025
plres@gsnLeftStringFontHeightF=0.03
plres@tiYAxisFontHeightF=0.03
plres@tiXAxisFontHeightF=0.025
plres@lbLabelFontHeightF=0.025
plres@cnLineLabelFontHeightF=0.025

plot(4)=gsn_csm_pres_hgt(wks,mask_diff,plres)
overlay(plot(4),plot0)
  ures@cnFillOn=True
  ures@cnLevelSpacingF      = 1.0                  ; contour spacing
  ures@cnMinLevelValF       = -4.                 ; min level
  ures@cnMaxLevelValF       =  7.                 ; max level
delete([/cold_color,warm_color,ures@cnFillColors/])
cold_color=ispan(30,90,13)
warm_color=ispan(128,245,13)
ures@cnFillColors=array_append_record(cold_color,warm_color,0)
  ures@gsnLeftString  = "(d)"
plot(1)=gsn_csm_pres_hgt(wks,positive_div,ures)
  ures@gsnLeftString  = "(e)"
  ures@cnMinLevelValF       = -5.                 ; min level
  ures@cnMaxLevelValF       =  12.                 ; max level
delete([/cold_color,warm_color,ures@cnFillColors/])
cold_color=ispan(30,90,11)
warm_color=ispan(128,245,9)
ures@cnFillColors=array_append_record(cold_color,warm_color,0)
plot(3)=gsn_csm_pres_hgt(wks,negative_div,ures)
  ures@cnLevelSpacingF      = 0.5                  ; contour spacing
  ures@cnMinLevelValF       = -6.                 ; min level
  ures@cnMaxLevelValF       =  4.                 ; max level
  ures@gsnLeftString  = ""
  ures@cnLinesOn=True
  ures@cnLineLabelsOn=True
  ures@cnFillOn=False
  ures@cnInfoLabelOn=False
;  ures@cnLineLabelFontHeightF=0.014
plot1=gsn_csm_pres_hgt(wks,diff_div,ures)
plres@gsnLeftString="(f)"
plot(5)=gsn_csm_pres_hgt(wks,mask_div,plres)
overlay(plot(5),plot1)
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
gsn_panel(wks,plot,(/3,2/),resP)
end  
