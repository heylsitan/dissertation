;Usage: plot slope of global annual t and global winter t
;Author: Heyl 20101012
;;rewrite on 20150826

pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2015_forest/figure_S1_S2/"

f=addfile(pathin+"cru/cru_ts3.22.1901.2013.tmp.dat.nc","r")
time=f->time
yrstart=1988
yrlast=2011
yyyy=cd_calendar(time,-1)/100
iyyyy=ind(yyyy.ge.yrstart .and. yyyy .le. yrlast)
iyyyy=iyyyy+2
print("ok")
t=f->tmp(iyyyy,:,:)
lon=f->lon
lat=f->lat
t_DJF=month_to_season(t,"OND")
t_ano_DJF=dim_rmvmean_n_Wrap(t_DJF,0)
printVarSummary(t_ano_DJF)
year=ispan(0,23,1)
slope_DJF=regCoef(year,t_DJF(lat|:,lon|:,time|:))
;copyatt(slope_DJF,t_DJF)
slope_DJF!0="lat"
slope_DJF&lat=lat
slope_DJF!1="lon"
slope_DJF&lon=lon
printVarSummary(slope_DJF)
print("calculate no error")
;;*******output nc*************
system("/bin/rm "+pathin+"cru/figure_S1_slope_winter_cru_1988_2011.nc")
fout=addfile(pathin+"cru/figure_S1_slope_winter_cru_1988_2011.nc","c")
;fout->lat=lat
;fout->lon=lon
;fout->time=t_DJF&time
fout->t_DJF=t_DJF
fout->t_ano_DJF=t_ano_DJF
fout->slope_DJF=slope_DJF
print("save no error")
;************plot slope_DJF *********
  wks = gsn_open_wks("eps" ,pathout+"figure_S1_slope_winter_cru_1988_2011")               ; open ps file
gsn_define_colormap(wks,"BlWhRe")  ; choose colormap

 res                      = True               ; plot mods desired
res@cnFillOn             = True               ; color contours
res@cnLinesOn            = False              ; default is True
res@cnLineLabelsOn       = False              ; default is True
res@gsnMaximize          = True               ; make ps, pdf, eps large
 ;---This resource not needed in NCL V6.1.0
;res@gsnSpreadColors      = True               ; use full range of colormap
res@cnLevelSelectionMode="ExplicitLevels"
res@cnLevels=fspan(-0.25,0.4,14)
res@cnFillColors=(/16,24,32,35,40,48,54,57,60,63,66,69,72,75,78,81,84,87,90/)


res@gsnLeftString      = ""
res@gsnCenterString         = "DJF: 1988-2011"
plot  = gsn_csm_contour_map_ce(wks,slope_DJF,res)
