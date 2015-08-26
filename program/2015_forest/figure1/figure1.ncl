;;usage: compare to IPCC figure 2.14
;;Author: Heyl 20150210
;;change range of siberia to 45-65N 55-120E
;;rewrite on 20150826

pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2015_forest/figure1/"

f1=addfile(pathin+"GISS/GISS_anom.nc","r")
t1=f1->giss_ano

t1_global=month_to_annual(dim_avg_n_Wrap(t1,(/1,2/)),1)
t1_siberia=month_to_annual(dim_avg_n_Wrap(t1(time|:,{lat|45:65},{lon|55:120}),(/1,2/)),1)
t1_nh=month_to_annual(dim_avg_n_Wrap(t1(time|:,{lat|0:90},lon|:),(/1,2/)),1)
printVarSummary(t1_global)
;print(t1_nh&year)

f2=addfile(pathin+"GHCN/tmp/GHCN_anom.nc","r")
t2=f2->ghcn_ano
t2_global=month_to_annual(dim_avg_n_Wrap(t2,(/1,2/)),1)
t2_siberia=month_to_annual(dim_avg_n_Wrap(t2(time|:,{lat|45:65},{lon|55:120}),(/1,2/)),1)
t2_nh=month_to_annual(dim_avg_n_Wrap(t2(time|:,{lat|0:90},lon|:),(/1,2/)),1)

f3=addfile(pathin+"cru/CRU_anom.nc","r")
t3=f3->cru_ano
t3_global=month_to_annual(dim_avg_n_Wrap(t3,(/1,2/)),1)
t3_siberia=month_to_annual(dim_avg_n_Wrap(t3(time|:,{lat|45:65},{lon|55:120}),(/1,2/)),1)
t3_nh=month_to_annual(dim_avg_n_Wrap(t3(time|:,{lat|0:90},lon|:),(/1,2/)),1)
print(t3_siberia)
exit
wgts=filwgts_normal(9,4/2.15,0)
wgt_t1_nh=wgt_runave_Wrap(t1_nh,wgts,1)
wgt_t1_siberia=wgt_runave_Wrap(t1_siberia,wgts,1)
wgt_t2_nh=wgt_runave_Wrap(t2_nh,wgts,1)
wgt_t2_siberia=wgt_runave_Wrap(t2_siberia,wgts,1)
wgt_t3_nh=wgt_runave_Wrap(t3_nh,wgts,1)
wgt_t3_siberia=wgt_runave_Wrap(t3_siberia,wgts,1)

;;average in three decadal
nh_mean_cru_98=conform_dims(15,avg(t3_nh(97:111)),-1)
nh_mean_cru_83=conform_dims(15,avg(t3_nh(82:96)),-1)
nh_mean_cru_40=conform_dims(15,avg(t3_nh(39:53)),-1)
nh_mean_ghcn_98=conform_dims(15,avg(t2_nh(97:111)),-1)
nh_mean_ghcn_83=conform_dims(15,avg(t2_nh(82:96)),-1)
nh_mean_ghcn_40=conform_dims(15,avg(t2_nh(39:53)),-1)
nh_mean_giss_98=conform_dims(15,avg(t1_nh(97:111)),-1)
nh_mean_giss_83=conform_dims(15,avg(t1_nh(82:96)),-1)
nh_mean_giss_40=conform_dims(15,avg(t1_nh(39:53)),-1)

siberia_mean_cru_98=conform_dims(15,avg(t3_siberia(97:111)),-1)
siberia_mean_cru_83=conform_dims(15,avg(t3_siberia(82:96)),-1)
siberia_mean_cru_40=conform_dims(15,avg(t3_siberia(39:53)),-1)
siberia_mean_ghcn_98=conform_dims(15,avg(t2_siberia(97:111)),-1)
siberia_mean_ghcn_83=conform_dims(15,avg(t2_siberia(82:96)),-1)
siberia_mean_ghcn_40=conform_dims(15,avg(t2_siberia(39:53)),-1)
siberia_mean_giss_98=conform_dims(15,avg(t1_siberia(97:111)),-1)
siberia_mean_giss_83=conform_dims(15,avg(t1_siberia(82:96)),-1)
siberia_mean_giss_40=conform_dims(15,avg(t1_siberia(39:53)),-1)
;print(t2_siberia)
;;trend

wks=gsn_open_wks("eps",pathout+"figure1")
res=True
res@gsnFrame=False
res@gsnDraw=False
res@vpWidthF=0.7
res@vpHeightF=0.4
res@trXMinF=1900
res@trXMaxF=2013
res@trYMaxF=1.3
res@trYMinF=-1.0
res@xyDashPatterns=(/0,1/)
res@xyLineThicknessF=3.0
res@xyLineColor="black"
res@gsnXYAboveFillColors="blue"
res@gsnXYBelowFillColors="red"

res@gsnYRefLine=0
res@gsnYRefLineDashPattern=1

res@tmXBMode="Explicit"
res@tmXBValues=ispan(1900,2010,20)
res@tmXBLabels=ispan(1900,2010,20)
res@tmXBMinorValues=ispan(1900,2010,10)
res@tiYAxisString=""
res@tmXBLabelFontHeightF=0.025
res@tmXBLabelFontThicknessF=2
res@tmYLLabelFontHeightF=0.025
res@tmYLLabelFontThicknessF=2

polyres=True
polyres@gsLineColor="red"
polyres@gsLineThicknessF=2

polyres2=polyres
polyres2@gsLineColor="orange"

;year=ispan(0,1355,1)/12.+1901
year=ispan(1901,2013,1)
plot=new(3,graphic)
dum=new(3,graphic)
data=new((/6,113/),float)
data(0,:)=wgt_t1_nh
data(1,:)=wgt_t1_siberia
data(2,:)=wgt_t2_nh
data(3,:)=wgt_t2_siberia
data(4,:)=wgt_t3_nh
data(5,:)=wgt_t3_siberia
plot(0)=gsn_csm_xy(wks,year,data(4:5,:),res)  ;;cru
plot(1)=gsn_csm_xy(wks,year,data(0:1,:),res)  ;;giss
plot(2)=gsn_csm_xy(wks,year,data(2:3,:),res)  ;;ghcn

dummy=new(18,graphic)
plres=True
plres@gsLineColor="blue"
plres@gsLineThicknessF=4
;plres@gsLineOpacityF=0.6
plres1=plres
plres1@gsLineColor="orange"
plres2=plres
plres2@gsLineColor="red"

;dummy(0)=gsn_add_polyline(wks,plot(0),year(97:111),nh_mean_cru_98,plres)
;dummy(1)=gsn_add_polyline(wks,plot(0),year(82:96),nh_mean_cru_83,plres)
;dummy(2)=gsn_add_polyline(wks,plot(0),year(39:53),nh_mean_cru_40,plres)
;dummy(3)=gsn_add_polyline(wks,plot(0),year(97:111),siberia_mean_cru_98,plres1)
;dummy(4)=gsn_add_polyline(wks,plot(0),year(82:96),siberia_mean_cru_83,plres1)
;dummy(5)=gsn_add_polyline(wks,plot(0),year(39:53),siberia_mean_cru_40,plres1)
;dummy(6)=gsn_add_polyline(wks,plot(1),year(97:111),nh_mean_giss_98,plres)
;dummy(7)=gsn_add_polyline(wks,plot(1),year(82:96),nh_mean_giss_83,plres)
;dummy(8)=gsn_add_polyline(wks,plot(1),year(39:53),nh_mean_giss_40,plres)
;dummy(9)=gsn_add_polyline(wks,plot(1),year(97:111),siberia_mean_giss_98,plres1)
;dummy(10)=gsn_add_polyline(wks,plot(1),year(82:96),siberia_mean_giss_83,plres1)
;dummy(11)=gsn_add_polyline(wks,plot(1),year(39:53),siberia_mean_giss_40,plres1)
;dummy(12)=gsn_add_polyline(wks,plot(2),year(97:111),nh_mean_ghcn_98,plres)
;dummy(13)=gsn_add_polyline(wks,plot(2),year(82:96),nh_mean_ghcn_83,plres)
;dummy(14)=gsn_add_polyline(wks,plot(2),year(39:53),nh_mean_ghcn_40,plres)
;dummy(15)=gsn_add_polyline(wks,plot(2),year(97:111),siberia_mean_ghcn_98,plres1)
;dummy(16)=gsn_add_polyline(wks,plot(2),year(82:96),siberia_mean_ghcn_83,plres1)
;dummy(17)=gsn_add_polyline(wks,plot(2),year(39:53),siberia_mean_ghcn_40,plres1)

txres=True
txres@txFontHeightF=0.03
txres@txJust="CenterLeft"
txres@txFontThicknessF=2.0
dum0=gsn_add_text(wks,plot(0),"(A) CRU",1910,1.0,txres)
dum1=gsn_add_text(wks,plot(1),"(B) GISS",1910,1.0,txres)
dum2=gsn_add_text(wks,plot(2),"(C) GHCN",1910,1.0,txres)

resP=True
resP@gsnMaximize=True
gsn_panel(wks,plot,(/3,1/),resP)
;frame(wks)
;draw(plot)
