;usage: base on blkind_c60.nc to get blk_day_c60.nc
;author: heyl 2012/10/17
;note: blkind_arr blkind_2d blkfre_2d
;ouput: ATL_blk_day_c60.nc
;;rewrite on 20150825

;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*****************************************************
begin
pathin="/home/yongli/yongli/dissertation/data/block/"

f=addfile(pathin+"no_spatial_blkind_c60.nc","r")
blkind_tmp=f->blkind ;(366,64,nlon)=0 ; here blkind don't check block wether last for 5 days or not
blkind=blkind_tmp
blkind(:,:,0:141)=blkind_tmp(:,:,2:143)
blkind(:,:,142:143)=blkind_tmp(:,:,0:1)
	printVarSummary(blkind)
;	print(sss)
;printMinMax(blkind,True)
;lon=fspan(0,357.5,144)
lon=blkind&lon
;;;;;;;;;;;******this is ATL sector
;sector limits longitude 
;ATL 100w-0
;EUR 0-90E
;WPA 90E-180
;EPA 180-100w
;now for ATL don't chande order of longitude
lonw=260
lone=0
id_lonw=ind(lon .eq. lonw)
id_lone=ind(lon .eq. lone)
print(id_lonw)
print(id_lone)
;	new_blkind=conform((/366*64,144/),blkind)
;	opt=True
;	opt@fout="ATL"
;	write_matrix(blkind(:,0,id_lonw:id_lone),"29I3",opt)
blkind_arr=new((/31,12,64/),"integer")
locate_sec=new((/366,64/),"integer",999)
blkind_sec=new(366*64-16,"integer") ;jian qu run nian
blkind_arr=default_fillvalue("integer")
blkind_sec=0
count=0
do iyear=0,63 
  do iday=0,365
  if ismissing(blkind(iday,iyear,0)) then 
  continue
  else
	locate_sec(iday,iyear)=count
    do ilon=id_lonw,id_lone
	if ((blkind(iday,iyear,ilon) .ne. 0) .and. (blkind(iday,iyear,ilon+1) .ne. 0) .and. (blkind(iday,iyear,ilon-1) .ne. 0)) then
	print(count)
	blkind_sec(count)=1
	break
	end if
    end do
   	count=count+1
   end if 
   end do
end do
;print(count)
;;;temporal constraint 
;TAPBUC,366*64,blkind_sec
mday=366*64-16
do iday=2,mday-3
     if (blkind_sec(iday) .eq. 0) .and. \
	(blkind_sec(iday-1) .eq. 1) .and. \
	(blkind_sec(iday-2) .eq. 1) .and. \
	(blkind_sec(iday+1) .eq. 1) .and. \
	(blkind_sec(iday+2) .eq. 1) then
	blkind_sec(iday)=1
     end if
end do

do iday=0,mday-6
if((blkind_sec(iday) .eq. 1) .and. \
   (blkind_sec(iday+1) .eq. 0) .and. \
   (blkind_sec(iday+2) .eq. 1) .and. \
   (blkind_sec(iday+3) .eq. 1) .and. \
   (blkind_sec(iday+4) .eq. 1) .and. \
   (blkind_sec(iday+5) .eq. 1)) then
blkind_sec(iday+1)=1
end if
if ((blkind_sec(iday) .eq. 1) .and. \
   (blkind_sec(iday+1) .eq. 1) .and. \
   (blkind_sec(iday+2) .eq. 1) .and. \
   (blkind_sec(iday+3) .eq. 1) .and. \
   (blkind_sec(iday+4) .eq. 0) .and. \
   (blkind_sec(iday+5) .eq. 1)) then
blkind_sec(iday+4)=1
end if
end do
icount=0
do iday=0,mday-1
if (blkind_sec(iday) .eq. 1) then icount=icount+1 end if
if ((blkind_sec(iday) .eq. 0) .and. (icount .ge. 1) .and. (icount .le. 4)) then
	do ka=1,icount 
	blkind_sec(iday-ka)=0
	end do
	icount=0
end if
if (blkind_sec(iday) .eq. 0 .and. icount .gt. 4) then icount=0 end if
end do
;;;;;;;; TAPBUC over
print("start to convert to day month year")
do iday=0,365
  do iyear=0,63
    md=monthday(iyear+1948,iday+1) ;1949 366 get missing value so 
	if md .eq. -9999 then 
	continue
	else
    day=md%100-1
    mon=md/100-1
;    print(md)
    blkind_arr(day,mon,iyear)=blkind_sec(locate_sec(iday,iyear))
	end if
  end do
end do
;;;;;;;;;;;;;;;
;;statistic monthly blocking day  blkind_2d
;blkind_2d=new((/12,64/),"integer",default_fillvalue("integer"))
blkind_2d=dim_sum_n_Wrap(blkind_arr,0)

;;;;;;;;;;;blocking day /days of month = frequency
blkfre_2d=new((/12,64/),"float",default_fillvalue("float"))
do mon=0,11
  do year=0,63
monday=days_in_month(year+1948,mon+1)
blkfre_2d(mon,year)=blkind_2d(mon,year)/monday
  end do
end do
;;;;output blkind_arr blkind_2d blkfre_2d
blkind_arr@descript="ATL blkind after constraint (grid where don't satisfy temporal and spatial constraint change to zero"
blkind_2d@descript="ATL monthly average blkind"
blkfre_2d@descript="ATL block day in the sector divided total number of the month"
system("/bin/rm -f "+pathin+"ATL_blk_day_c60.nc")
fout=addfile(pathin+"ATL_blk_day_c60.nc","c")
fout->blkind_arr=blkind_arr
fout->blkind_2d=blkind_2d
fout->blkfre_2d=blkfre_2d
end

