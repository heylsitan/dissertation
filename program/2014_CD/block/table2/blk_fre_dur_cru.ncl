;usage: base on cru landsea thermal index, block duration in every new sector  EUR WPA EPA ATL
;author: heyl 2012/11/16
;;rewrite on 20150825

;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*****************************************************
begin
pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/block/"

f=addfile(pathin+"block/duration.nc","r")
dur_win_atl=f->dur_win_atl ;(100,63)
dur_win_eur=f->dur_win_eur
dur_win_wpa=f->dur_win_wpa
dur_win_epa=f->dur_win_epa
;dur_atl=new((/6,63/),"integer")
;dur_eur=new((/6,63/),"integer")
;dur_wpa=new((/6,63/),"integer")
;dur_epa=new((/6,63/),"integer")
day=ispan(1,100,1)
event_atl=dim_sum_n(dur_win_atl,0) ; a winter have how many event
event_eur=dim_sum_n(dur_win_eur,0)
event_wpa=dim_sum_n(dur_win_wpa,0)
event_epa=dim_sum_n(dur_win_epa,0)
event_atl(ind(event_atl .eq. 0))=default_fillvalue("integer")
event_eur(ind(event_eur .eq. 0))=default_fillvalue("integer")
event_wpa(ind(event_wpa .eq. 0))=default_fillvalue("integer")
event_epa(ind(event_epa .eq. 0))=default_fillvalue("integer")

dur_atl=dim_sum_n(dur_win_atl*conform(dur_win_atl,day,0),0)/event_atl  ;blocked days in winter /events
dur_eur=dim_sum_n(dur_win_eur*conform(dur_win_eur,day,0),0)/event_eur
dur_wpa=dim_sum_n(dur_win_wpa*conform(dur_win_wpa,day,0),0)/event_wpa
dur_epa=dim_sum_n(dur_win_epa*conform(dur_win_epa,day,0),0)/event_epa

;positive_year=(/1950,1951,1956,1957,1965,1969,1972,1979,1985/)-1948
;negative_year=(/1983,1987,1992,1995,1998,1999,2002,2004,2007/)-1948
;;;;in sector use local deltat to decide positive and negative year
ff=addfile(pathin+"cru/cru_index.nc","r")
pacific=ff->pacific
atlantic=ff->atlantic
cru_index=ff->cru_index

positive_atl=ind(dim_standardize(cru_index(0:62),1) .gt. 1.079) ;;in order to get same number of year in different phase, now number is 9
negative_atl=ind(dim_standardize(cru_index(0:62),1) .lt. -0.9)
positive_wpa=ind(dim_standardize(cru_index(0:62),1) .gt. 1.08)
negative_wpa=ind(dim_standardize(cru_index(0:62),1) .lt. -0.9)
print(positive_atl)
print(negative_atl)
print(positive_wpa)
print(negative_wpa)

pos=new(4,"float")
neg=new(4,"float")
pos(0)=dim_avg(dur_atl(positive_atl))
neg(0)=dim_avg(dur_atl(negative_atl))
pos(1)=dim_avg(dur_eur(positive_atl))
neg(1)=dim_avg(dur_eur(negative_atl))
pos(2)=dim_avg(dur_wpa(positive_wpa))
neg(2)=dim_avg(dur_wpa(negative_wpa))
pos(3)=dim_avg(dur_epa(positive_wpa))
neg(3)=dim_avg(dur_epa(negative_wpa))
print(pos)
print(neg)
;;;;;;;;;;;;;;;;plot 
wks=gsn_open_wks("eps",pathout+"fre_dur_4region_cru")
;wks=gsn_open_wks("eps","/home/heyl/block/block/picture/fre_dur_4region_cru2")
res=True
res@trXMinF=0
res@trXMaxF=16
res@trYMinF=0
res@trYMaxF=20

res@gsnDraw=True
res@gsnFrame=False

res@tiYAxisString="Duration(Days)"
res@gsnXYBarChart=True
res@gsnXYBarChartBarWidth=1
res@tmXBMode="Explicit"
res@tmXBValues=(/2,6,10,14/)
res@tmXBLabels=(/"ATL","EUR","WPA","EPA"/)
plot=new(2,graphic)

res@gsnXYBarChartColors=(/"white"/)
plot(0)=gsn_csm_xy(wks,ispan(1,13,4),pos,res)
res@gsnXYBarChartColors=(/"black"/)
plot(1)=gsn_csm_xy(wks,ispan(2,14,4),neg,res)

lbres=True
lbres@lbFillColors=(/"white","black"/)
lbres@lbMonoFillPattern=True
labels=(/"Positive","negative"/)
lbres@vpWidthF=0.2
lbres@vpHeightF=0.1
gsn_labelbar_ndc(wks,2,labels,0.58,0.8,lbres)

frame(wks)
end








