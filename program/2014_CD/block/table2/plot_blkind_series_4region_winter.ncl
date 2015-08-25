;Usage: calculate trend of block days in four region for table2
;Author  heyl
;date:  2012/11/16
;;rewrite on 20150825

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
pathin="/home/yongli/yongli/dissertation/data/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/block/"

f1=addfile(pathin+"block/EUR_blk_day_c60.nc","r")
f2=addfile(pathin+"block/WPA_blk_day_c60.nc","r")
f3=addfile(pathin+"block/EPA_blk_day_c60.nc","r")
f4=addfile(pathin+"block/ATL_blk_day_c60.nc","r")

blkind_EUR=f1->blkind_2d
blkind_WPA=f2->blkind_2d
blkind_EPA=f3->blkind_2d
blkind_ATL=f4->blkind_2d
;;winter DJF 
blk_EUR_winter=new(63,"integer")
blk_WPA_winter=new(63,"integer")
blk_EPA_winter=new(63,"integer")
blk_ATL_winter=new(63,"integer")
do iyear=1,63
blk_EUR_winter(iyear-1)=blkind_EUR(11,iyear-1)+blkind_EUR(0,iyear)+blkind_EUR(1,iyear)
blk_WPA_winter(iyear-1)=blkind_WPA(11,iyear-1)+blkind_WPA(0,iyear)+blkind_WPA(1,iyear)
blk_EPA_winter(iyear-1)=blkind_EPA(11,iyear-1)+blkind_EPA(0,iyear)+blkind_EPA(1,iyear)
blk_ATL_winter(iyear-1)=blkind_ATL(11,iyear-1)+blkind_ATL(0,iyear)+blkind_ATL(1,iyear)
end do
print(blk_EPA_winter)
print(blk_ATL_winter)

	
w=filwgts_normal(7,1.0,0)
wgt_blk_EUR_winter=wgt_runave(blk_EUR_winter,w,0)
wgt_blk_WPA_winter=wgt_runave(blk_WPA_winter,w,0)
wgt_blk_EPA_winter=wgt_runave(blk_EPA_winter,w,0)
wgt_blk_ATL_winter=wgt_runave(blk_ATL_winter,w,0)
x=ispan(0,62,1)
rc_EUR=regline(x,blk_EUR_winter)
yreg_EUR=rc_EUR*x+rc_EUR@yintercept
rc_WPA=regline(x,blk_WPA_winter)
yreg_WPA=rc_WPA*x+rc_WPA@yintercept
rc_EPA=regline(x,blk_EPA_winter)
yreg_EPA=rc_EPA*x+rc_EPA@yintercept
rc_ATL=regline(x,blk_ATL_winter)
yreg_ATL=rc_ATL*x+rc_ATL@yintercept

print(rc_ATL)
print(rc_EUR)
print(rc_WPA)
print(rc_EPA)

x2=x(7:42)
x3=x(42:62)
rc_ATL2=regline(x2,blk_ATL_winter(7:42))
yreg_ATL2=rc_ATL2*x2+rc_ATL2@yintercept
rc_ATL3=regline(x3,blk_ATL_winter(42:62))
yreg_ATL3=rc_ATL3*x3+rc_ATL3@yintercept

;;;;;;;;;;;plot
wks= gsn_open_wks("eps",pathout+"blkind_series_4region_winter")
gsn_define_colormap(wks,"BlWhRe") 
res		= True
res@gsnDraw	= False  
res@gsnFrame	= False

res@tiYAxisString="block days"
res@gsnXYBarChart=True
res@gsnMaximize   =True
polyres		= True
polyres@gsLineColor="black"
polyres@gsLineThicknessF=3.0
plots=new(4,graphic)
resP		= True
resP@gsnMaximize = True
res@tiMainString="(b) EUR(winter)"
year=x+1949
year2=x2+1949
year3=x3+1949
plots(1)=gsn_csm_xy(wks,year,blk_EUR_winter,res)
dum1=gsn_add_polyline(wks,plots(1),year,(/wgt_blk_EUR_winter/),polyres)
dum2=gsn_add_polyline(wks,plots(1),year,(/yreg_EUR/),polyres)
res@tiMainString="(c) WPA(winter)"
plots(2)=gsn_csm_xy(wks,year,blk_WPA_winter,res)
dum3=gsn_add_polyline(wks,plots(2),year,(/wgt_blk_WPA_winter/),polyres)
dum4=gsn_add_polyline(wks,plots(2),year,(/yreg_WPA/),polyres)
res@tiMainString="(d) EPA(winter)"
plots(3)=gsn_csm_xy(wks,year,blk_EPA_winter,res)
dum5=gsn_add_polyline(wks,plots(3),year,(/wgt_blk_EPA_winter/),polyres)
dum6=gsn_add_polyline(wks,plots(3),year,(/yreg_EPA/),polyres)
res@tiMainString="(a) ATL(winter)"
plots(0)=gsn_csm_xy(wks,year,blk_ATL_winter,res)
dum7=gsn_add_polyline(wks,plots(0),year,(/wgt_blk_ATL_winter/),polyres)
dum8=gsn_add_polyline(wks,plots(0),year,(/yreg_ATL/),polyres)
dum9=gsn_add_polyline(wks,plots(0),year2,(/yreg_ATL2/),polyres)
dum10=gsn_add_polyline(wks,plots(0),year3,(/yreg_ATL3/),polyres)
gsn_panel(wks,plots,(/2,2/),resP)

	end



