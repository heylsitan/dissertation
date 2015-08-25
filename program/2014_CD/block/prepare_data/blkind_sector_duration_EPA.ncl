;usage: calculate duration of block in sector from EPA_blk_day_c60.nc, category blocking by tm criteria
;and spatial constraint(delta lon > 3)
;author: heyl 2012/10/26
;note: should be no spatial constraint so caseid=0
;ouput: blk_dur_sector_EPA.nc
;;rewrite on 20150825

;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*****************************************************
begin
pathin="/home/yongli/yongli/dissertation/data/block/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/block/"

f=addfile(pathin+"EPA_blk_day_c60.nc","r")
blkind=f->blkind_arr ;(31,12,64)
blkind!0="day"
blkind!1="mon"
blkind!2="year"
blkind_tmp=blkind(year|:,mon|:,day|:)
;printVarSummary(blkind_tmp)
blkind_2d=reshape(blkind_tmp,(/64,12*31/))
blkind_win=new((/64,3*31/),"float")
;print("ok")
do iyear=0,62
   blkind_win(iyear,0:30)=blkind_tmp(iyear,11,:)
   blkind_win(iyear,31:61)=blkind_tmp(iyear+1,0,:)
   blkind_win(iyear,62:92)=blkind_tmp(iyear+1,1,:)
end do

;print("ok")
;print(blkind_win(11,:))
;print(blkind(:,1,12))
;print(ss)
;printVarSummary(blkind)
dur_arr=new((/100,64/),"integer")
dur_arr=0
;blkind_2d=conform_dims((/12*31,64/),blkind,1)
lunga=0
flag=0
do iyear=0,63
 tmp=blkind_2d(iyear,:)
 
 tmpb=tmp(ind(.not.ismissing(tmp)))
 daycount=dimsizes(tmpb)
 do dcount=0,daycount-1
   if (tmpb(dcount) .eq. 1) then
   flag=1
   lunga=lunga+1
   end if
   if ((tmpb(dcount) .eq. 0) .and. (flag .eq. 1)) then
;   print(lunga)
;   print(iyear)
   dur_arr(lunga,iyear)=dur_arr(lunga,iyear)+1
   flag=0
   lunga=0
   end if
   if (lunga .gt. 99) then lunga=99 end if
 end do
delete(tmpb)
end do
;print(sum(dur_arr))

;;;;;winter
dur_win=new((/100,63/),"integer")
dur_win=0
lunga=0
flag=0
delete(tmp)
do iyear=0,62
 tmp=blkind_win(iyear,:)
 tmpb=tmp(ind(.not.ismissing(tmp)))
 daycount=dimsizes(tmpb)
 do dcount=0,daycount-1
   if (tmpb(dcount) .eq. 1) then
   flag=1
   lunga=lunga+1
   end if
   if ((tmpb(dcount) .eq. 0) .and. (flag .eq. 1)) then
;   print(lunga)
;   print(iyear)
   dur_win(lunga,iyear)=dur_win(lunga,iyear)+1
   flag=0
   lunga=0
   end if
   if (lunga .gt. 99) then lunga=99 end if
 end do
delete(tmpb)
end do
fout=addfile(pathin+"duration.nc","w")
fout->dur_year_epa=dur_arr
fout->dur_win_epa=dur_win

block_event_year=dim_sum_n(dur_arr,0)
block_event_win =dim_sum_n(dur_win,0)
day=ispan(1,100,1)
block_event_year(ind(block_event_year .eq. 0))=default_fillvalue("integer")
block_event_win(ind(block_event_win .eq. 0))=default_fillvalue("integer")
duration_avg_year=dim_sum_n(conform(dur_arr,day,0)*dur_arr,0)/block_event_year
duration_avg_win=dim_sum_n(conform(dur_win,day,0)*dur_win,0)/block_event_win
;print(duration_avg_win)
event5_year=dim_sum_n(dur_arr(5:9,:),0)
event10_year=dim_sum_n(dur_arr(10::,:),0)
event5_year(ind(event5_year .eq. 0))=default_fillvalue("integer")
event10_year(ind(event10_year .eq. 0))=default_fillvalue("integer")
dur5_year=dim_sum_n(conform(dur_arr(5:9,:),day(5:9),0)*dur_arr(5:9,:),0)/event5_year
dur10_year=dim_sum_n(conform(dur_arr(10::,:),day(10::),0)*dur_arr(10::,:),0)/event10_year


event5_win=dim_sum_n(dur_win(5:9,:),0)
event10_win=dim_sum_n(dur_win(10::,:),0)
event5_win(ind(event5_win .eq. 0))=default_fillvalue("integer")
event10_win(ind(event10_win .eq. 0))=default_fillvalue("integer")
dur5_win=dim_sum_n(conform(dur_win(5:9,:),day(5:9),0)*dur_win(5:9,:),0)/event5_win
dur10_win=dim_sum_n(conform(dur_win(10::,:),day(10::),0)*dur_win(10::,:),0)/event10_win

w=filwgts_normal(7,1.0,0)
wgt_block_event_year=wgt_runave(block_event_year,w,0)
wgt_block_event_win=wgt_runave(block_event_win,w,0)
wgt_duration_avg_year=wgt_runave(duration_avg_year,w,0)
wgt_duration_avg_win=wgt_runave(duration_avg_win,w,0)
year=ispan(1948,2011,1)
win_year=ispan(1948,2010,1)
rc_block_event_year=regline(year(0:54),block_event_year(0:54))
yreg_event_year=rc_block_event_year*year(0:54)+rc_block_event_year@yintercept
rc_block_event_win=regline(win_year(0:54),block_event_win(0:54))
yreg_event_win=rc_block_event_win*win_year(0:54)+rc_block_event_win@yintercept
rc_duration_year=regline(year(0:54),duration_avg_year(0:54))
yreg_duration_year=rc_duration_year*year(0:54)+rc_duration_year@yintercept
rc_duration_win=regline(win_year(0:54),duration_avg_win(0:54))
yreg_duration_win=rc_duration_win*win_year(0:54)+rc_duration_win@yintercept
print(rc_duration_win)
;;;;;;;;;output
;system("/bin/rm -f /home/heyl/block/block/data/duration_envent_global.nc")
;fout=addfile("/home/heyl/block/block/data/duration_envent_global.nc","c")
;fout->block_event_year_atl=block_event_year
;fout->block_event_win_atl=block_event_win
;fout->duration_avg_year_atl=duration_avg_year
;fout->duration_avg_win_atl=duration_avg_win
;end
;;;------------plot -------------------
wks= gsn_open_wks("eps",pathout+"frequency_duration_EPA")
gsn_define_colormap(wks,"BlWhRe") 
res             = True
res@gsnDraw     = False
res@gsnFrame    = False
;
res@gsnXYBarChart=True
res@gsnMaximize   =True
res@trYMinF=0
res@trYMaxF=14
res@xyLineColors="black"
polyres         = True
polyres@gsLineColor="black"
polyres@gsLineThicknessF=2.0

resP            = True
resP@gsnMaximize = True
plots=new(4,graphic)
res@tiYAxisString="envent numbers"
res@tiXAxisString="year"
res@tiMainString="all year (EPA)"
plots(0)=gsn_csm_xy(wks,year,block_event_year,res)
dum1=gsn_add_polyline(wks,plots(0),year,wgt_block_event_year,polyres)
dum5=gsn_add_polyline(wks,plots(0),year,yreg_event_year,polyres)
res@tiMainString="winter (EPA)"
plots(1)=gsn_csm_xy(wks,win_year,block_event_win,res)
dum2=gsn_add_polyline(wks,plots(1),win_year,wgt_block_event_win,polyres)
dum6=gsn_add_polyline(wks,plots(1),win_year,yreg_event_win,polyres)
res@tiYAxisString="duration days"
res@tiMainString="all year (EPA)"
res@trYMaxF=30
plots(2)=gsn_csm_xy(wks,year,duration_avg_year,res)
dum3=gsn_add_polyline(wks,plots(2),year,wgt_duration_avg_year,polyres)
dum7=gsn_add_polyline(wks,plots(2),year,yreg_duration_year,polyres)
res@tiMainString="winter (EPA)"
plots(3)=gsn_csm_xy(wks,win_year,duration_avg_win,res)
dum4=gsn_add_polyline(wks,plots(3),win_year,wgt_duration_avg_win,polyres)
dum8=gsn_add_polyline(wks,plots(3),win_year,yreg_duration_win,polyres)
gsn_panel(wks,plots,(/2,2/),resP)
;;;another page

res@trYMaxF=15
res@tiYAxisString="event bnumers"
res@tiMainString="all year(EPA):6-10days"
plots(0)=gsn_csm_xy(wks,year,event5_year,res)
res@tiMainString="all year(EPA):>10days"
plots(1)=gsn_csm_xy(wks,year,event10_year,res)
res@tiYAxisString="duration days"
res@tiMainString="all year(EPA):6-10days"
res@trYMaxF=15
plots(2)=gsn_csm_xy(wks,year,dur5_year,res)
res@tiMainString="all year(EPA):>10days"
res@trYMaxF=50
plots(3)=gsn_csm_xy(wks,year,dur10_year,res)
gsn_panel(wks,plots,(/2,2/),resP)

res@tiYAxisString="event bnumers"
res@tiMainString="winter (EPA):6-10days"
res@trYMaxF=15
plots(0)=gsn_csm_xy(wks,win_year,event5_win,res)
res@tiMainString="winter (EPA):>10days"
plots(1)=gsn_csm_xy(wks,win_year,event10_win,res)
res@tiYAxisString="duration days"
res@tiMainString="winter (EPA):6-10days"
res@trYMaxF=15
plots(2)=gsn_csm_xy(wks,win_year,dur5_win,res)
res@tiMainString="winter (EPA):>10days"
res@trYMaxF=50
plots(3)=gsn_csm_xy(wks,win_year,dur10_win,res)
gsn_panel(wks,plots,(/2,2/),resP)

end

