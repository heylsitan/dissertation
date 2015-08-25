;usage: base on landsea phase, block days in every new sector  EUR WPA EPA ATL
;author: heyl 2012/11/16
;note: calculate block days from blkind_2d  phase year already know
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
dur_win_atl=f->dur_win_atl ;;(100,63)
dur_win_eur=f->dur_win_eur
dur_win_wpa=f->dur_win_wpa
dur_win_epa=f->dur_win_epa
day=ispan(1,100,1)
winblk_ATL=dim_sum_n(dur_win_atl*conform(dur_win_atl,day,0),0)
winblk_EUR=dim_sum_n(dur_win_eur*conform(dur_win_eur,day,0),0)
winblk_WPA=dim_sum_n(dur_win_wpa*conform(dur_win_wpa,day,0),0)
winblk_EPA=dim_sum_n(dur_win_epa*conform(dur_win_epa,day,0),0)
;f1=addfile("/home/heyl/block/block/data/c60/sector/EUR_blk_day_c60.nc","r")
;f2=addfile("/home/heyl/block/block/data/c60/sector/WPA_blk_day_c60.nc","r")
;f3=addfile("/home/heyl/block/block/data/c60/sector/EPA_blk_day_c60.nc","r")
;f4=addfile("/home/heyl/block/block/data/c60/sector/ATL_blk_day_c60.nc","r")
;
;blk2d_EUR=f1->blkind_2d
;blk2d_WPA=f2->blkind_2d
;blk2d_EPA=f3->blkind_2d
;blk2d_ATL=f4->blkind_2d
;;printVarSummary(blk2d_EUR)
;winblk_EUR=new(63,"integer")
;winblk_WPA=new(63,"integer")
;winblk_EPA=new(63,"integer")
;winblk_ATL=new(63,"integer")
;do iyear=1,63
;winblk_EUR(iyear-1)=blk2d_EUR(11,iyear-1)+blk2d_EUR(0,iyear)+blk2d_EUR(1,iyear)
;winblk_WPA(iyear-1)=blk2d_WPA(11,iyear-1)+blk2d_WPA(0,iyear)+blk2d_WPA(1,iyear)
;winblk_EPA(iyear-1)=blk2d_EPA(11,iyear-1)+blk2d_EPA(0,iyear)+blk2d_EPA(1,iyear)
;winblk_ATL(iyear-1)=blk2d_ATL(11,iyear-1)+blk2d_ATL(0,iyear)+blk2d_ATL(1,iyear)
;end do
;;;;in sector use local hgt index  to decide positive and negative year
ff=addfile(pathin+"cru/cru_index.nc","r")
pacific=ff->pacific
atlantic=ff->atlantic
cru_index=ff->cru_index

positive_pac=ind(dim_standardize(cru_index(0:62),1) .gt. 1.079)
negative_pac=ind(dim_standardize(cru_index(0:62),1) .lt. -0.9)
positive_atl=ind(dim_standardize(cru_index(0:62),1) .gt. 1.08)
negative_atl=ind(dim_standardize(cru_index(0:62),1) .lt. -0.9)
;positive_pac=ind(dim_standardize(pacific(0:60),1) .gt. 1)
;negative_pac=ind(dim_standardize(pacific(0:60),1) .lt. -1)
;positive_atl=ind(dim_standardize(atlantic(0:60),1) .gt. 1)
;negative_atl=ind(dim_standardize(atlantic(0:60),1) .lt. -1)
print(positive_pac)
print(negative_pac)
print(positive_atl)
print(negative_atl)
;;EUR ATL own atlantic; WPA EPA own pacific
pos_winblk=new(4,"float")
neg_winblk=new(4,"float")
pos_winblk(0)=dim_avg(winblk_ATL(positive_atl))
neg_winblk(0)=dim_avg(winblk_ATL(negative_atl))
pos_winblk(1)=dim_avg(winblk_EUR(positive_atl))
neg_winblk(1)=dim_avg(winblk_EUR(negative_atl))
pos_winblk(2)=dim_avg(winblk_WPA(positive_pac))
neg_winblk(2)=dim_avg(winblk_WPA(negative_pac))
pos_winblk(3)=dim_avg(winblk_EPA(positive_pac))
neg_winblk(3)=dim_avg(winblk_EPA(negative_pac))
print(pos_winblk)
print(neg_winblk)
;;;;;;;;;;;;;;;;plot 
wks=gsn_open_wks("eps",pathout+"blk_ls_phase_4region_cru")
;wks=gsn_open_wks("eps","/home/heyl/picture/cru_sector/blk_ls_phase_4region_cru")
res=True
res@trXMinF=0
res@trXMaxF=16
res@trYMinF=0
res@trYMaxF=40

res@gsnDraw=True
res@gsnFrame=False

res@gsnXYBarChart=True
res@gsnXYBarChartBarWidth=1
res@tmXBMode="Explicit"
res@tmXBValues=(/2,6,10,14/)
res@tmXBLabels=(/"ATL","EUR","WPA","EPA"/)
res@tiYAxisString="Block Days"

res@gsnXYBarChartColors=(/"white"/)
plot1=gsn_csm_xy(wks,ispan(1,13,4),pos_winblk,res)
res@gsnXYBarChartColors=(/"black"/)
plot2=gsn_csm_xy(wks,ispan(2,14,4),neg_winblk,res)

lbres=True
lbres@lbFillColors=(/"white","black"/)
lbres@lbMonoFillPattern=True
labels=(/"Positive","negative"/)
lbres@vpWidthF=0.2
lbres@vpHeightF=0.1
gsn_labelbar_ndc(wks,2,labels,0.58,0.8,lbres)

frame(wks)
end








