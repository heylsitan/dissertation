;;Usage: plot eof2 pattern and identify four key area as figure 1 in paper
;;Author: Heyl rewriten on 20150822
pathin="/home/yongli/yongli/dissertation/data/ncep/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure1/"

f=addfile(pathin+"eof_hgt_ncep_2014CD.nc","r")
eof2=f->eof(1,:,:)  ;-180,180
printVarSummary(eof2)

;;;;;plot;;;;;;;;;;;;
wks=gsn_open_wks("eps",pathout+"figure1_eof2_ncep_hgt")
 gsn_define_colormap(wks,"BlWhRe")       ; choose colormap
res=True
res@gsnDraw=False
res@gsnFrame=False
;res@gsnSpreadColors=True
res@gsnAddCyclic=True
res@mpMinLatF=20
res@mpMaxLatF=80
res@gsnPolar="NH"
res@cnFillColors=(/27,34,41,48,52,56,60,64,68,72,76,80/)
res@cnFillOn=True
res@cnLinesOn=False
res@lbLabelBarOn=True
res@gsnCenterString="HGT:DJF 1948-2011"
res@gsnRightString="16.6%"
res@gsnLeftString=""
plot=gsn_csm_contour_map_polar(wks,eof2,res)

;;;add box;;;;;;;
resp=True
resp@gsLineColor="black"
resp@gsLineThicknessF=2.0
dum=new((/4,4/),graphic)
xlon1=(/-70,-40,-40,-70,-70/)
ylat1=(/57.5,57.5,77.5,77.5,57.5/)
xlon2=(/-130,-100,-100,-130,-130/)
ylat2=(/40,40,60,60,40/)
xlon3=(/-180,-150,-150,-180,-180/)
ylat3=(/40,40,60,60,40/)
xlon4=(/80,120,120,80,80/)
ylat4=(/40,40,60,60,40/)

do i=0,3
dum(0,i)=gsn_add_polyline(wks,plot,xlon1(i:i+1),ylat1(i:i+1),resp)
dum(1,i)=gsn_add_polyline(wks,plot,xlon2(i:i+1),ylat2(i:i+1),resp)
dum(3,i)=gsn_add_polyline(wks,plot,xlon4(i:i+1),ylat4(i:i+1),resp)
end do
dum(2,0)=gsn_add_polyline(wks,plot,(/170,170/),(/40,60/),resp)
dum(2,1)=gsn_add_polyline(wks,plot,(/-150,-150/),(/40,60/),resp)
dum(2,2)=gsn_add_polyline(wks,plot,(/170,180/),(/40,40/),resp)
dum(2,3)=gsn_add_polyline(wks,plot,(/170,180/),(/60,60/),resp)
dum2=gsn_add_polyline(wks,plot,(/-150,-180/),(/40,40/),resp)
dum3=gsn_add_polyline(wks,plot,(/-150,-180/),(/60,60/),resp)
draw(plot)
frame(wks)

