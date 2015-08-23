;;Usage: plot time serires of land sea index based on cru temperature
;;Author: Heyl rewrite on 20150823
pathin="/home/yongli/yongli/dissertation/data/cru/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure2/"

ff=addfile(pathin+"cru_sst.nc","r")
time=ff->time
yrstart=1948
yrlast=2010
yyyy=cd_calendar(time,-1)/100
iyyyy=ind(yyyy.ge.yrstart .and. yyyy .le. yrlast)
iyyyy=iyyyy+2
temp=ff->cru_sst(iyyyy,:,:)
;;cru is -180..180 cahnge to 0..360
temp=lonFlip(temp)
printVarSummary(temp)
t_DJF=month_to_season(temp,"OND")

rad=4.*atan(1.)/180
clat=ff->lat
clat=sqrt(cos(rad*clat))
;printVarSummary(clat)
wgt=t_DJF
wgt=t_DJF*conform(t_DJF,clat,1)
printVarSummary(wgt)
;;;0-360
pacific=dim_avg_n_Wrap(wgt(time|:,{lat|40:60},{lon|80:120}),(/1,2/))-dim_avg_n_Wrap(wgt(time|:,{lat|40:60},{lon|170:210}),(/1,2/))
atlantic=dim_avg_n_Wrap(wgt(time|:,{lat|40:60},{lon|230:260}),(/1,2/))-dim_avg_n_Wrap(wgt(time|:,{lat|57.5:77.5},{lon|290:320}),(/1,2/))
cru_index=pacific+atlantic
;print(pacific)
pacific_ano=dim_rmvmean(pacific)
atlantic_ano=dim_rmvmean(atlantic)
cru_index_ano=dim_rmvmean(cru_index)
year=ispan(1949,2011,1)
;;;compare cru_index and cru_index_ano
print(cru_index)
print(cru_index_ano)
;;;*****************weight 7years gauss filter************
w=filwgts_normal(7,1.0,0)
wgt_cru_index=wgt_runave(cru_index_ano,w,0)
wgt_pacific=wgt_runave(pacific_ano,w,0)
wgt_atlantic=wgt_runave(atlantic_ano,w,0)
system("/bin/rm -f "+pathin+"cru_index.nc")
fout=addfile(pathin+"cru_index.nc","c")
fout->pacific=pacific
fout->atlantic=atlantic
fout->cru_index=cru_index
fout->year=year
;;;;;;;;;;;;;;;;;;;;;;
wks2=gsn_open_wks("eps",pathout+"figure2")

        res             = True
        res@gsnDraw     = False
        res@gsnFrame    = False
        res@tiYAxisString="Anomalies"
        res@tiXAxisString="Years"
        res@gsnYRefLine = 0.0
        res@gsnAboveYRefLineColor="red"
        res@gsnBelowYRefLineColor="blue"
        res@gsnXYBarChart=True
        res@vpWidthF=1
        res@vpHeightF=0.5
res@gsnLeftStringFontHeightF=0.05
  res@tmXBMode = "Explicit"	
  res@tmXBValues = (/1950,1960,1970,1980,1990,2000,2010/)
  res@tmXBLabels = (/"1950","1960","1970","1980","1990","2000","2010"/)
  res@tmXBMinorValues  = ispan(1948,2011,1)
  res@tmYROn=False
  res@tmXTOn=False
res@tmXBLabelFontHeightF=0.04
res@tmYLLabelFontHeightF=0.04
res@tiYAxisFontHeightF=0.04
res@tiXAxisFontHeightF=0.04
;       res@vpXF=0.15
;res@vpYF=0.85
        polyres         = True
        polyres@gsLineColor="black"
        polyres@gsLineThicknessF=3.0
;        plots=new(3,graphic)
        resP            = True
        resP@gsnMaxmize = True
        res@gsnLeftString=""
        plots=gsn_csm_xy(wks2,year,cru_index_ano,res)
        dum=gsn_add_polyline(wks2,plots(0),year,(/wgt_cru_index/),polyres)
;        res@gsnLeftString="(b)"
;        plots(1)=gsn_csm_xy(wks2,year,pacific_ano,res)
;        dum2=gsn_add_polyline(wks2,plots(1),year,(/wgt_pacific/),polyres)
;        res@gsnLeftString="(c)"
;        plots(2)=gsn_csm_xy(wks2,year,atlantic_ano,res)
;        dum3=gsn_add_polyline(wks2,plots(2),year,(/wgt_atlantic/),polyres)
        gsn_panel(wks2,plots,(/1,1/),resP)


