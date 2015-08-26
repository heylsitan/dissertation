;;Usage: adjust all dataset to smae climate 1961-1990
;;Author: Heyl 20150207
;;rewrite on 20150826
pathin="/home/yongli/yongli/dissertation/data/"

f1=addfile(pathin+"GISS/gistemp250.nc","r")
time1=f1->time
yyyy1=cd_calendar(time1,-1)/100
iyyyy1=ind(yyyy1 .ge. 1901 .and. yyyy1 .le. 2013)
t1=short2flt(f1->tempanomaly(iyyyy1,:,:))

climyr1=ind(yyyy1 .ge. 1961 .and. yyyy1 .le. 1990)
climt1=clmMonTLL(short2flt(f1->tempanomaly(climyr1,:,:)))
t1_ano=calcMonAnomTLL(t1,climt1)
printVarSummary(t1_ano)

f2=addfile(pathin+"GHCN/tmp/temp_GHCN_1880_2015.nc","r")
time2=f2->time
yyyy2=cd_calendar(time2,-1)/100
iyyyy2=ind(yyyy2 .ge. 1901 .and. yyyy2 .le. 2013)
t2=f2->t(iyyyy2,:,:)
climyr2=ind(yyyy2 .ge. 1961 .and. yyyy2 .le. 1990)
climt2=clmMonTLL(f2->t(climyr2,:,:))
t2_ano=calcMonAnomTLL(t2,climt2)

f3=addfile(pathin+"cru/cru_ts3.22.1901.2013.tmp.dat.nc","r")
time3=f3->time
yyyy3=cd_calendar(time3,-1)/100
iyyyy3=ind(yyyy3 .ge. 1901 .and. yyyy3 .le. 2013)
t3=tofloat(f3->tmp(iyyyy3,:,:))
t3!0="time"
t3!1="lat"
t3!2="lon"
t3&time=f3->time
t3&lat=f3->lat
t3&lon=f3->lon
climyr3=ind(yyyy3 .ge. 1961 .and. yyyy3 .le. 1990)
climt3=tofloat(clmMonTLL(f3->tmp(climyr3,:,:)))
t3_ano=calcMonAnomTLL(t3,climt3)
printVarSummary(t3_ano)
;print(t3_ano(0,270,430))
;exit
;;output
system("rm -f "+pathin+"GISS/GISS_anom.nc")
fout1=addfile(pathin+"GISS/GISS_anom.nc","c")
fout1->giss_ano=t1_ano

system("rm -f "+pathin+"GHCN/tmp/GHCN_anom.nc")
fout2=addfile(pathin+"GHCN/tmp/GHCN_anom.nc","c")
fout2->ghcn_ano=t2_ano

system("rm -f "+pathin+"cru/CRU_anom.nc")
fout3=addfile(pathin+"cru/CRU_anom.nc","c")
fout3->cru_ano=t3_ano

