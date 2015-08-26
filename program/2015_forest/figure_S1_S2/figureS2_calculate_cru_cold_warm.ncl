;usage: plot the T series in global Siberia during annual,cold,warm
;Author: Heyl 20150213
;;expand siberia 55-120E 45-65N
;;rewrite on 20150826
path="/home/yongli/yongli/dissertation/data/"

f=addfile(path+"cru/cru_ts3.22.1901.2013.tmp.dat.nc","r")
yrstart=1901
yrlast=2013
time=f->time
yyyy=cd_calendar(time,-1)/100
iyyyy=ind(yyyy .ge. yrstart .and. yyyy .le. yrlast)  
t=f->tmp(iyyyy,:,:)
;;anomaly
iyyyy2=ind(yyyy .ge. 1961 .and. yyyy .le. 1990)
tmp=f->tmp(iyyyy2,:,:)
clim=clmMonTLL(tmp)
t_ano=calcMonAnomTLL(t,clim)

nmon=dimsizes(t&time)
nlat=dimsizes(t&lat)
nlon=dimsizes(t&lon)
nyr=nmon/12
delete([/t,tmp/])

t_ann=month_to_annual(t_ano,1)
tmp1=reshape(t_ano,(/nyr,12,nlat,nlon/))
t_warm=dim_avg_n_Wrap(tmp1(:,4:8,:,:),1)
tmp2=reshape(t_ano(3:nmon-1-12+3,:,:),(/nyr-1,12,nlat,nlon/))
t_cold=dim_avg_n_Wrap(tmp2(:,7:11,:,:),1)
delete([/tmp1,tmp2/])
;;attributes
t_warm!0="year"
t_warm!1="lat"
t_warm!2="lon"
t_warm&lat=t_ano&lat
t_warm&lon=t_ano&lon
t_cold!0="yr"
t_cold!1="lat"
t_cold!2="lon"
t_cold&lat=t_ano&lat
t_cold&lon=t_ano&lon

lat=f->lat
rad=4.*atan(1.)/180.
clat   = sqrt( cos(rad*lat) )

wt_ann=t_ann
wt_ann=t_ann*conform(t_ann,clat,1)
printVarSummary(wt_ann)
t_global_ann=dim_avg_n_Wrap(wt_ann,(/1,2/))
t_nh_ann=dim_avg_n_Wrap(wt_ann(:,{0:90},:),(/1,2/))
t_siberia_ann=dim_avg_n_Wrap(wt_ann(year|:,{lat|45:65},{lon|55:120}),(/1,2/))
delete(wt_ann)

wt_warm=t_warm
wt_warm=t_warm*conform(t_warm,clat,1)
t_global_warm=dim_avg_n_Wrap(wt_warm,(/1,2/))
t_nh_warm=dim_avg_n_Wrap(wt_warm(:,{0:90},:),(/1,2/))
t_siberia_warm=dim_avg_n_Wrap(wt_warm(year|:,{lat|45:65},{lon|55:120}),(/1,2/))
delete(wt_warm)

wt_cold=t_cold
wt_cold=t_cold*conform(t_cold,clat,1)
t_global_cold=dim_avg_n_Wrap(wt_cold,(/1,2/))
t_nh_cold=dim_avg_n_Wrap(wt_cold(:,{0:90},:),(/1,2/))
t_siberia_cold=dim_avg_n_Wrap(wt_cold(yr|:,{lat|45:65},{lon|55:120}),(/1,2/))
delete(wt_cold)

;; not save
system("rm -f table1_cru_cold_warm.nc")
fout=addfile("table1_cru_cold_warm.nc","c")
fout->t_global_ann=t_global_ann
fout->t_global_warm=t_global_warm
fout->t_global_cold=t_global_cold
fout->t_nh_ann=t_nh_ann
fout->t_nh_warm=t_nh_warm
fout->t_nh_cold=t_nh_cold
fout->t_siberia_ann=t_siberia_ann
fout->t_siberia_warm=t_siberia_warm
fout->t_siberia_cold=t_siberia_cold
