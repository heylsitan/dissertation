;usage: calculate ghgs and ghgn from hgt_500_daily.nc, category blocking by tm criteria
;and spatial constraint(delta lon > 3)
;author: heyl 2012/10/17
;note: should be no spatial constraint so caseid=0
;ouput: blkind_flag_c60.nc
;;rewrite on 20150825

;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*****************************************************
begin
pathin="/home/yongli/yongli/dissertation/data/ncep/"
pathout="/home/yongli/yongli/dissertation/data/block/"

f=addfile(pathin+"hgt_500_daily.nc","r")
hgt=f->hgt ;(day,year,lat,lon)
lon=f->lon
lat=f->lat
nlon=dimsizes(lon)
width=20
gnmax=-10
ior=1 ;width corresponding grid numbers of delta longitude
latc=60
caseid=0
lat_north=latc+width
lat_south=latc-width

id_latc=ind(lat .eq. latc)
id_latn=ind(lat .eq. lat_north)
id_lats=ind(lat .eq. lat_south)
wks=new((/366,64,144/),"float",999)
wkn=wks
blkfre=new(nlon,"float")
blkind=new((/366,64,nlon/),"integer")
blkind=0
blkfre=0
do iyear=0,63
  do iday=0,365
if ismissing(hgt(iday,iyear,0,0)) then 
print(iday)
else
    do ilon=0,143
x1=hgt(iday,iyear,id_latn-ior,ilon)-hgt(iday,iyear,id_latc-ior,ilon)
x2=hgt(iday,iyear,id_latn,ilon)   -hgt(iday,iyear,id_latc,ilon)
x3=hgt(iday,iyear,id_latn+ior,ilon)-hgt(iday,iyear,id_latc+ior,ilon)
wkn(iday,iyear,ilon)=min((/x1,x2,x3/))/width

x1=hgt(iday,iyear,id_latc-ior,ilon)-hgt(iday,iyear,id_lats-ior,ilon)
x2=hgt(iday,iyear,id_latc,ilon)   -hgt(iday,iyear,id_lats,ilon)
x3=hgt(iday,iyear,id_latc+ior,ilon)-hgt(iday,iyear,id_lats+ior,ilon)
wks(iday,iyear,ilon)=max((/x1,x2,x3/))/width
     end do
end if
  end do
end do
if caseid .eq. 0 then
	print("no spatial constraint")
	do iyear=0,63
	   do iday=0,365 
	     if ismissing(hgt(iday,iyear,0,0)) then
;	     continue
	     blkind(iday,iyear,:)=default_fillvalue("integer")
	     else
	       do ilon=0,nlon-1
		if (wkn(iday,iyear,ilon) .lt. gnmax) .and. (wks(iday,iyear,ilon) .gt. 0.0) then
;		blkfre(ilon)=blkfre(ilon)+1
		blkind(iday,iyear,ilon)=1
		end if
	       end do
	     end if
	   end do
	end do 
else
	print("checking if the surrounding lon is in blocking or not")
 
do iyear=0,63
  do iday=0,365
      if ismissing(hgt(iday,iyear,0,0)) then
;      continue
;	print(iday)
	blkind(iday,iyear,:)=default_fillvalue("integer")
      else 
	   do ilon=1,nlon-2
	    if((wkn(iday,iyear,ilon) .lt. gnmax) .and. (wks(iday,iyear,ilon) .gt. 0.0)) .and. ((wkn(iday,iyear,ilon+1) .lt. gnmax) .and. (wks(iday,iyear,ilon+1) .gt. 0.0)) .and. ((wkn(iday,iyear,ilon-1) .lt. gnmax) .and. (wks(iday,iyear,ilon-1) .gt. 0.0)) then
        blkfre(ilon)=blkfre(ilon)+1
        blkind(iday,iyear,ilon)=1
	print("ok")
      	    end if
	ilon=0
           if((wkn(iday,iyear,ilon) .lt. gnmax) .and. (wks(iday,iyear,ilon) .gt. 0.0)) .and. ((wkn(iday,iyear,ilon+1) .lt. gnmax) .and. (wks(iday,iyear,ilon+1) .gt. 0.0)) .and. ((wkn(iday,iyear,nlon-1) .lt. gnmax) .and. (wks(iday,iyear,nlon-1) .gt. 0.0)) then
        blkfre(ilon)=blkfre(ilon)+1
        blkind(iday,iyear,ilon)=1
           end if
	ilon=nlon-1
           if((wkn(iday,iyear,ilon) .lt. gnmax) .and. (wks(iday,iyear,ilon) .gt. 0.0)) .and. ((wkn(iday,iyear,0) .lt. gnmax) .and. (wks(iday,iyear,0) .gt. 0.0)) .and. ((wkn(iday,iyear,ilon-1) .lt. gnmax) .and. (wks(iday,iyear,ilon-1) .gt. 0.0)) then
        blkfre(ilon)=blkfre(ilon)+1
        blkind(iday,iyear,ilon)=1
           end if
	    end do
       end if
   end do
end do
end if
opt=True
        opt@fout="europe2"
        write_matrix(blkind(:,20,4:32),"29I3",opt)

;;;because 0    1...nlon-2 nlon-1
;	  miss  yes   yes   miss
;so ilon=0 and ilon=nlon-1 method is different 

;blkfre is same with figure1 in huang's paper
;blkind is to output
blkind!0="day"
blkind!1="year"
blkind!2="lon"
blkind&day=ispan(1,366,1)
blkind&year=ispan(1948,2011,1)
blkind&lon=lon

system("/bin/rm -f "+pathout+"no_spatial_blkind_c60.nc")
fout=addfile(pathout+"no_spatial_blkind_c60.nc","c")
fout->blkind=blkind
fout->blkfre=blkfre
end




