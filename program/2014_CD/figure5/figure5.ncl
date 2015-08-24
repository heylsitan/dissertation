;;Usage: plot time series of westly index  proposed by lijianping and tio index (chen wen)
;;Author: Heyl rewrite on 20150823
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"        ; functions required to
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"                 ; plot.  include before
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"               ; begin

begin
pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure5/"

f=addfile(pathin+"cru/cru_index.nc","r")
cru_index=f->cru_index
cru_index_ano=dim_rmvmean(cru_index)
w=filwgts_normal(7,1.0,0)
wgt_cru_index_ano=wgt_runave(cru_index_ano,w,0)
;;==================================westly index lijianping ========
fslp=addfile(pathin+"ncep/ncep_slp.mon.mean.nc","r")
time=fslp->time
yrstart=1948
yrlast=2010
yyyy=cd_calendar(time,-1)/100
iyyyy=ind(yyyy.ge.yrstart .and. yyyy .le. yrlast)
iyyyy=iyyyy+2
slp=fslp->slp(iyyyy,:,:)
slp_DJF=month_to_season(slp,"OND")
slp_DJF_zm=dim_avg_Wrap(slp_DJF)

zi_li=slp_DJF_zm(:,22)-slp_DJF_zm(:,10)
zi_li_ano=dim_rmvmean_Wrap(zi_li)

wgt_zi_li_ano=wgt_runave(zi_li_ano,w,0)

;*********************tio ******************
a=addfile(pathin+"epflux/NCEP_EPDJF_wave123.nc","r")
div=a->div  ;;63,17,73
tio=div(year|0:62,{lev|500},{lat|50})-div(year|0:62,{lev|300},{lat|40})
tio_ano=dim_rmvmean_Wrap(tio)

;;*****************weight 7years gauss filter************
wgt_tio_ano=wgt_runave(tio_ano,w,0)
acr2=escorc(wgt_tio_ano,wgt_cru_index_ano)
acr1=escorc(wgt_zi_li_ano,wgt_cru_index_ano)
nr=dimsizes(wgt_tio_ano)
prob1=rtest(acr1,nr,0)
prob2=rtest(acr2,nr,0)
print(prob1)
print(prob2)
;;;;;;;;;;;;;;;;;plot ************************
year=ispan(1949,2011,1)
	wks		= gsn_open_wks("eps",pathout+"figure5_cru_index_tio_zi")
	gsn_define_colormap(wks,"BlWhRe") 
	res		= True
	res@gsnDraw	= False  
	res@gsnFrame	= False
res@tmXBLabelFontHeightF=0.025  ;used to ce plot
res@tmYLLabelFontHeightF=0.025
res@gsnStringFontHeightF=0.03
res@tiYAxisFontHeightF=0.025
res@tiXAxisFontHeightF=0.025
res@vpWidthF=0.7
res@vpHeightF=0.4
	res@tiYAxisString="Anomalies"
	res@gsnYRefLine = 0.0
	res@gsnAboveYRefLineColor="red"
	res@gsnBelowYRefLineColor="blue"
	res@gsnXYBarChart=True
  res@tmXBMode = "Explicit"
  res@tmXBValues = (/1950,1960,1970,1980,1990,2000,2010/)
  res@tmXBLabels = (/"1950","1960","1970","1980","1990","2000","2010"/)
  res@tmXBMinorValues  = ispan(1948,2011,1)
  res@tmYROn=False
  res@tmXTOn=False
;res@tmXBLabelFontHeightF=0.04
;res@tmYLLabelFontHeightF=0.04
;res@tiYAxisFontHeightF=0.04
;res@tiXAxisFontHeightF=0.04

	polyres		= True
	polyres@gsLineColor="black"
	polyres@gsLineThicknessF=3.0

	plots=new(2,graphic)
	resP		= True
	resP@gsnMaxmize	= True
	res@gsnLeftString="(a)"
	res@gsnRightString="Cor="+sprintf("%4.2f",escorc(wgt_zi_li_ano,wgt_cru_index_ano))
	plots(0)=gsn_csm_xy(wks,year,zi_li_ano,res)
	dum=gsn_add_polyline(wks,plots(0),year,(/wgt_zi_li_ano/),polyres)
;	res@tiMainString="TIO"
	res@gsnLeftString="(b)"
	res@gsnRightString="Cor="+sprintf("%4.2f",escorc(wgt_tio_ano,wgt_cru_index_ano))
	plots(1)=gsn_csm_xy(wks,year,tio_ano,res)
	dum2=gsn_add_polyline(wks,plots(1),year,(/wgt_tio_ano/),polyres)
	gsn_panel(wks,plots,(/2,1/),resP)

end




