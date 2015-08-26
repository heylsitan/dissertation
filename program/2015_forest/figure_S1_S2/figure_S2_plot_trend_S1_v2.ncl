;;Usage: calculate trend in Siberia and NH during 1970-1997 and 1998-2011, add errbar
;;Author: Heyl 20150213
;;add error bar on 20150628
;;rewrite on 20150826
pathout="/home/yongli/yongli/dissertation/picture/2015_forest/figure_S1_S2/"

f=addfile("trend_cru.nc","r")
trend_nh_ann_98=f->trend_nh_ann_98
trend_nh_ann_70=f->trend_nh_ann_70
trend_siberia_ann_98=f->trend_siberia_ann_98
trend_siberia_ann_70=f->trend_siberia_ann_70
trend_nh_warm_98=f->trend_nh_warm_98
trend_nh_warm_70=f->trend_nh_warm_70
trend_siberia_warm_98=f->trend_siberia_warm_98
trend_siberia_warm_70=f->trend_siberia_warm_70
trend_nh_cold_98=f->trend_nh_cold_98
trend_nh_cold_70=f->trend_nh_cold_70
trend_siberia_cold_98=f->trend_siberia_cold_98
trend_siberia_cold_70=f->trend_siberia_cold_70

data=new((/4,3/),double)
;data(0,:)=(/0.225,0.161,0.298/)
;data(1,:)=(/0.394,0.165,0.574/)
;data(2,:)=(/0.125,0.204,-0.062/)
;data(3,:)=(/-0.105,0.033,-0.806/)
data(0,:)=(/trend_nh_ann_70,trend_nh_warm_70,trend_nh_cold_70/)*10
data(1,:)=(/trend_siberia_ann_70,trend_siberia_warm_70,trend_siberia_cold_70/)*10
data(2,:)=(/trend_nh_ann_98,trend_nh_warm_98,trend_nh_cold_98/)*10
data(3,:)=(/trend_siberia_ann_98,trend_siberia_warm_98,trend_siberia_cold_98/)*10

wks=gsn_open_wks("eps",pathout+"trend_S1_v2")

res=True
res@gsnFrame=False
res@gsnDraw=False
res@vpWidthF=0.7
res@vpHeightF=0.5
res@vpXF=0.15
res@trXMinF=0.4
res@trXMaxF=3.6
res@trYMinF=-1.8
res@trYMaxF=1.5
res@gsnXYBarChart=True
res@gsnXYBarChartBarWidth=0.15
res@tmXBMode="Explicit"
res@tmXBValues=(/1,2,3/)
res@tmXBLabels=(/"Annual","Warm Season","Cold Season"/)
;res@tmXBLabelFontHeightF=
res@gsnYRefLine=0.
res@tiYAxisString="Trend (~S~o~N~C/decade)"

plot=new(4,graphic)
res@gsnXYBarChartColors="red"
plot(0)=gsn_csm_xy(wks,fspan(0.775,2.775,3),data(0,:),res)
res@gsnXYBarChartColors="lightblue"
plot(1)=gsn_csm_xy(wks,fspan(0.925,2.925,3),data(1,:),res)
res@gsnXYBarChartColors="blue"
plot(2)=gsn_csm_xy(wks,fspan(1.075,3.075,3),data(2,:),res)
res@gsnXYBarChartColors="green"
plot(3)=gsn_csm_xy(wks,fspan(1.225,3.225,3),data(3,:),res)

;;;;add error bar
polyres=True
polyres@gsMarkerIndex=1
polyres@gsMarkerSizeF=0.02
polyres@gsLineThicknessF=2.
centers=new(12,graphic)
error_bar=new(12,graphic)
xp=(/0.775,0.925,1.075,1.225, 1.775,1.925,2.075,2.225, 2.775,2.925,3.075,3.225/)
yp=(/trend_nh_ann_70@rstd,trend_siberia_ann_70@rstd,trend_nh_ann_98@rstd,trend_siberia_ann_98@rstd, \
  trend_nh_warm_70@rstd,trend_siberia_warm_70@rstd,trend_nh_warm_98@rstd,trend_siberia_warm_98@rstd,\ 
  trend_nh_cold_70@rstd,trend_siberia_cold_70@rstd,trend_nh_cold_98@rstd,trend_siberia_cold_98@rstd/)
yp=yp*10 ;;per year to per decadal
print(yp)
cc=(/data(0,0),data(1,0),data(2,0),data(3,0),data(0,1),data(1,1),data(2,1),data(3,1),data(0,2),data(1,2),data(2,2),data(3,2)/)
do i=0,11
centers(i)=gsn_add_polymarker(wks,plot(3),xp(i),cc(i),polyres)
error_bar(i)=gsn_add_polyline(wks,plot(3),(/xp(i),xp(i)/),(/cc(i)+yp(i),cc(i)-yp(i)/),polyres)
end do

ebres=True
ebres@gsLineThicknessF=2.
width=0.02
ebt=new(12,graphic)
ebb=new(12,graphic)
do i=0,11
ebt(i)=gsn_add_polyline(wks,plot(3),(/xp(i)-width,xp(i)+width/),(/cc(i)+yp(i),cc(i)+yp(i)/),ebres)
ebb(i)=gsn_add_polyline(wks,plot(3),(/xp(i)-width,xp(i)+width/),(/cc(i)-yp(i),cc(i)-yp(i)/),ebres)
end do

lbres=True
lbres@vpWidthF=0.3
lbres@vpHeightF=0.1
lbres@lbBoxMajorExtentF=0.36
lbres@lbFillColors=(/"green","blue"/)
lbres@lbMonoFillPattern=True
;lbres@lbLabelFontHeightF=0.035
lbres@lbLabelJust="CenterLeft"
lbres@lbPerimOn=False
lbres@lgPerimColor="white"
labels=(/"Siberia (1998-2012)","NH (1998-2012)"/)
gsn_labelbar_ndc(wks,2,labels,0.47,0.8,lbres)
lbres@lbFillColors=(/"lightblue","red"/)
labels=(/"Siberia (1970-1997)","NH (1970-1997)"/)
gsn_labelbar_ndc(wks,2,labels,0.17,0.8,lbres)
draw(plot)
frame(wks)

