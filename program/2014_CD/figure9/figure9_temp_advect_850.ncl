;;;usage: calculate temperature advection in 850 and 700hpa that is related to the COWL
;;date: 20130713
;;rewrite on 20150825

;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*****************************************************
begin
pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure9/"

f=addfile(pathin+"ncep/eof_hgt_ncep_2014CD.nc","r")
;eof2=f->eof(1,:,:)  ;-180,180
cowl=-1.0*(f->eof_ts(1,:))
;printVarSummary(eof2)
printVarSummary(cowl)
;print(cowl)
;print(ss)
positive=ind(dim_standardize(cowl,0) .gt. 1)
negative=ind(dim_standardize(cowl,0) .lt. -1)
year=ispan(1949,2011,1)
positive_year=year(positive)
negative_year=year(negative)
print(positive_year)
print(negative_year)

;;calculate temperature advection
f1=addfile(pathin+"epflux/uwnd.mon.mean.nc","r")
f2=addfile(pathin+"epflux/vwnd.mon.mean.nc","r")
f3=addfile(pathin+"ncep/t.mon.pressure.nc","r")
time=f1->time
yrstart=1948
yrlast=2010
yyyy=cd_calendar(time,-1)/100
iyyyy=ind(yyyy.ge.yrstart .and. yyyy .le. yrlast)
iyyyy=iyyyy+2
u=short2flt(f1->uwnd(iyyyy,2,:,:)) ;;850hpa
v=short2flt(f2->vwnd(iyyyy,2,:,:)) ;;850hpa
t=short2flt(f3->air(iyyyy,2,:,:)) ;;850hpa
lon=f1->lon
lat=f1->lat
time2=u&time
ntime=dimsizes(time2)
nlat=dimsizes(lat)
nlon=dimsizes(lon)
;;;;;;;t_grad_lon and t_grad_lat
dlon=(lon(2)-lon(1))*0.0174533
dlat=(lat(2)-lat(1))*0.0174533
print(dlon)
print(dlat)
;print(ss)
dtdx=new((/ntime,nlat,nlon/),"float")
dtdy=new((/ntime,nlat,nlon/),"float")
do nl=0,nlat-1
dx=6378388.*cos(0.0174533*lat(nl))*dlon
dtdx(:,nl,:)=center_finite_diff(t(:,nl,:),dx,False,0)
end do
dy=-6378388*dlat
print(dy)
dtdy=center_finite_diff_n(t,dy,False,0,1)
advect=-u*dtdx-v*dtdy
;;;;;;;;;;other way to calculate advect

;dtdx=new((/ntime,nlat,nlon/),"float")
;dtdy=new((/ntime,nlat,nlon/),"float")
;dlon=(lon(2)-lon(1))*0.0174533
;dlat=(lat(2)-lat(1))*0.0174533
;dy=6378388*dlat
;do ilat=1,nlat-2
;  do ilon=0,nlon-1
;   dtdy(:,ilat,ilon)=(t(:,ilat-1,ilon)-t(:,ilat+1,ilon))/2.0/dy   ;;;because lat is from 90 to -90 but advect term is up minus down
;  end do
;end do
;  do ilon=0,nlon-1
;   dtdy(:,0,ilon)=(t(:,0,ilon)-t(:,1,ilon))/dy
;   dtdy(:,nlat-1,ilon)=(t(:,nlat-2,ilon)-t(:,nlat-1,ilon))/dy
;  end do
;
;do ilat=0,nlat-1
;  dx=6378388.*cos(0.0174533*lat(ilat))*dlon
;  do ilon=1,nlon-2
;   dtdx(:,ilat,ilon)=(t(:,ilat,ilon-1)-t(:,ilat,ilon+1))/2.0/dx ;;lon 0 to 360 but left minus right
;  end do
;end do
;  do ilat=0,nlat-1
;   dtdx(:,ilat,0)=(t(:,ilat,0)-t(:,ilat,1))/dx
;   dtdx(:,ilat,nlon-1)=(t(:,ilat,nlon-2)-t(:,ilat,nlon-1))/2.0/dx
;  end do
;
;advect=-u*dtdx-v*dtdy

printVarSummary(advect)
advect!0="time"
advect!1="lat"
advect!2="lon"
advect_DJF=month_to_season(advect,"OND")
advect_DJF&time=ispan(1949,2011,1)
advect_DJF&lat=lat
advect_DJF&lon=lon
printVarSummary(advect_DJF)
pos_advect_DJF=dim_avg_n_Wrap(advect_DJF(positive,:,:),0)
neg_advect_DJF=dim_avg_n_Wrap(advect_DJF(negative,:,:),0)

diff_advect=pos_advect_DJF-neg_advect_DJF

diff_advect!0="lat"
diff_advect!1="lon"
diff_advect&lat=lat
diff_advect&lon=lon
copyatt(pos_advect_DJF,diff_advect)
copyatt(neg_advect_DJF,diff_advect)
printVarSummary(diff_advect)
printMinMax(pos_advect_DJF,True)
printMinMax(neg_advect_DJF,True)
printMinMax(diff_advect,True)

varx=dim_variance_n_Wrap(advect_DJF({time|positive_year},lat|:,lon|:),0)
vary=dim_variance_n_Wrap(advect_DJF({time|negative_year},lat|:,lon|:),0)
sx=dimsizes(positive_year)
sy=dimsizes(negative_year)
s=sqrt((varx+vary)/(sx+sy-2))
s=where(s .eq. 0, default_fillvalue("integer"), s)
tt=diff_advect/s/sqrt(1.0/sx+1.0/sy)
t_diff=cdft_t(0.99,sx+sy-2)
mask_temp=mask(tt,tt .gt. -t_diff .and. tt .lt. t_diff,False)
copyatt(mask_temp,pos_advect_DJF)

wks=gsn_open_wks("eps",pathout+"temp_advect_850")
gsn_define_colormap(wks,"BlRe")
res=True
res@gsnDraw=False
res@gsnFrame=False

res@cnLevelSelectionMode="ManualLevels"
res@cnMinLevelValF=-10.0e-5
res@cnMaxLevelValF=10.0e-5
res@cnLevelSpacingF=1.0e-5
res@cnFillOn=True
res@cnLinesOn=False
res@cnLineLabelsOn=False

;res@gsnSpreadColors=True  ;;;;;;

;res@lbLabelAutoStride=True
;res@lbOrientation="vertical"
;res@lbLabelAngleF=0
;res@lbLabelFontHeightF=0.001
;res@lbLabelStride=1
;res@lbTitleOn=False ;turn on label title
; res@lbTitlePosition="Right"
; res@lbTitleDirection="Across"
; res@lbTitleString="()"
; res@lbTitleFont=21
; res@pmLabelTitleHeightF=0.05
 res@lbLabelFont=21 ;label font
 res@lbLabelFontThicknessF=2.2
; res@pmLabelBarHeightF=0.04
; res@pmLabelBarWidthF=0.45
; res@pmLabelBarOrthogonalPosF=0.12

 res@tiMainString="" ;add titles 
 res@tiXAxisString="" ;add xtitles
 res@tiYAxisString="" ;add ytitles
 res@tmXBLabelFont=22 ;x axis bottom font
 res@tmBorderThicknessF=2.5
 res@tmXBLabelFont=22;x axis bottom font
 res@tmYLLabelFont=22 ;y axis left font
 res@tmBorderThicknessF=2.5 ; linewidth scale factor of axis
 res@tmXBMajorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmXTMajorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmYLMajorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmYRMajorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmXTMinorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmXBMinorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmYLMinorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmYRMinorThicknessF=2.5 ; linewidth scale factor of axis
 res@tmXBMajorLengthF=0.01
 res@tmXBMinorLengthF=0.004
 res@tmXTMajorLengthF=0.01
 res@tmXTMinorLengthF=0.004
 res@tmYLMajorLengthF=0.01
 res@tmYLMinorLengthF=0.004
 res@tmYRMajorLengthF=0.01
 res@tmYRMinorLengthF=0.004
 res@tmXBLabelFontHeightF=0.014
 res@tmYLLabelFontHeightF=0.014
 res@tiXAxisFont=22
 res@tiYAxisFont=22

 res@vpWidthF=0.7		; set width of plot 
 res@vpHeightF=0.6		; set height of plot
 res@vpXF=0.15		; set left hand side start point of plot
				; as vpWidthF = .8, plot will occupy .1->.9 in NDC coords.
 res@vpYF=0.9		; set top start point of plot


 res@gsnMaximize=False
; res@gsnSpreadColors=True
 ;res@gsnAddCyclic=False ; regional data
 res@gsnLeftString="(a)"
 res@gsnRightString=""
 res@gsnCenterString=""
;warm_color=ispan(30,90,toint(60/5.))
;cold_color=ispan(130,230,toint(100/10.))
;warm_color(5)=0
;cold_color(0)=0
;fill_colors=array_append_record(warm_color,cold_color,0)
res@cnFillColors=(/15,17,25,27,30,32,35,37,40,42,0,0,53,55,58,60,63,65,68,70,78,80/);fill_colors

; txres               = True                     ; text mods desired
; txres@txFontHeightF = 0.021                     ; font smaller. default big
; txres@txFont=21
; txres@gsnFrame=False
; gsn_text_ndc(wks,"(:S:o:N:C)",0.71,0.405,txres)
 plot=new(3,graphic)
;levels=ispan(-5,10,1)*1.0e-5
;  res@lbLabelStrings       =sprintf("%6.2e",levels);(/"-12e-5","-8e-5","-4e-5","0","4e-5","8e-5","12e-5"/) 

 plot(0)=gsn_csm_contour_map(wks,pos_advect_DJF,res)
res@gsnLeftString="(b)" 
plot(1)=gsn_csm_contour_map(wks,neg_advect_DJF,res)
;delete([/warm_color,cold_color,fill_colors,res@cnFillColors/])
res@cnMinLevelValF=-4.0e-5
res@cnMaxLevelValF=4.0e-5
res@cnLevelSpacingF=0.50e-5
;levels2=ispan(-5,5,1)*1.0e-5
;res@lbLabelStrings       :=sprintf("%6.2e",levels2);(/"-12e-5","-8e-5","-4e-5","0","4e-5","8e-5","12e-5"/) 
;;delete([/warm_color,cold_color,fill_colors,res@cnFillColors/])
;warm_color=ispan(30,90,toint(60/4.))
;cold_color=ispan(130,230,toint(100/4.))
;warm_color(4)=0
;cold_color(0)=0
;fill_colors=array_append_record(warm_color,cold_color,0)
;;res@cnFillColors=fill_colors
res@gsnLeftString="(c)" 
res@cnInfoLabelOn=False
res@cnFillColors:=(/15,25,28,30,32,35,37,40,0,0,55,57,60,63,65,68,70,80/);fill_colors
plot(2)=gsn_csm_contour_map(wks,diff_advect,res)
plres=True
plres@gsnDraw=False
plres@gsnFrame=False
plres@vpWidthF=0.6
plres@vpHeightF=0.7
;plres@mpMinLatF=0
;plres@mpMaxLatF=90
;plres@gsnPolar="NH"

plres@cnMonoFillPattern=True
plres@cnFillPattern=6

plres@cnLinesOn=False;True
plres@cnFillOn=True
plres@lbLabelBarOn         = False
plres@cnInfoLabelOn=False
plres@cnMonoFillColor=True
plres@cnFillColor="black"
;plres@gsnStringFontHeightF=0.025
;plres@gsnPolarLabelFontHeightF=0.018
;plres@gsnPolarLabelDistance    = 1.08
plres@gsnLeftString=""
plres@gsnRightString=""
plres@gsnCenterString=""
 plot1=gsn_csm_contour(wks,mask_temp,plres)
overlay(plot(2),plot1)
resP=True
resP@gsnMaximize=True
gsn_panel(wks,plot,(/3,1/),resP)

end




