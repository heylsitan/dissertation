;;Usage: calculate the sum in positive nad negative lsi in 5-9 days and longer than 10 days
;author: heyl 2012/11/16
;rewrite on 20150825

;****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*****************************************************
begin
pathin="/home/yongli/yongli/dissertation/data/"

f=addfile(pathin+"block/duration.nc","r")
dur_win_atl=f->dur_win_atl
dur_win_eur=f->dur_win_eur
dur_win_wpa=f->dur_win_wpa
dur_win_epa=f->dur_win_epa
dur_atl=new((/2,63/),"integer")
dur_eur=new((/2,63/),"integer")
dur_wpa=new((/2,63/),"integer")
dur_epa=new((/2,63/),"integer")
day=ispan(1,100,1)
;dur_win_atl=dur_win_atl*conform(dur_win_atl,day,0)
;dur_win_eur=dur_win_eur*conform(dur_win_atl,day,0)
;dur_win_wpa=dur_win_wpa*conform(dur_win_atl,day,0)
;dur_win_epa=dur_win_epa*conform(dur_win_atl,day,0)
dur_atl(0,:)=dim_sum_n(dur_win_atl(4:8,:),0)    ;5-9 days
dur_atl(1,:)=dim_sum_n(dur_win_atl(9:,:),0)   ;10-14 days
dur_eur(0,:)=dim_sum_n(dur_win_eur(4:8,:),0)
dur_eur(1,:)=dim_sum_n(dur_win_eur(9:,:),0)
dur_wpa(0,:)=dim_sum_n(dur_win_wpa(4:8,:),0)
dur_wpa(1,:)=dim_sum_n(dur_win_wpa(9:,:),0)
dur_epa(0,:)=dim_sum_n(dur_win_epa(4:8,:),0)
dur_epa(1,:)=dim_sum_n(dur_win_epa(9:,:),0)

;positive_year=(/1950,1951,1956,1957,1965,1969,1972,1979,1985/)-1948
;negative_year=(/1983,1987,1992,1995,1998,1999,2002,2004,2007/)-1948
;;;;in sector use local deltat to decide positive and negative year
ff=addfile(pathin+"cru/cru_index.nc","r")
pacific=ff->pacific
atlantic=ff->atlantic
cru_index=ff->cru_index

positive_atl=ind(dim_standardize(cru_index(0:62),1) .gt. 1.079)
negative_atl=ind(dim_standardize(cru_index(0:62),1) .lt. -0.9)
positive_wpa=ind(dim_standardize(cru_index(0:62),1) .gt. 1.08)
negative_wpa=ind(dim_standardize(cru_index(0:62),1) .lt. -0.9)

print(positive_atl)
print(negative_atl)

;positive_atl=ind(dim_standardize(cru_index(0:60),1) .gt. 1)
;negative_atl=ind(dim_standardize(cru_index(0:60),1) .lt. -1)
;positive_eur=ind(dim_standardize(cru_index(0:60),1) .gt. 1)
;negative_eur=ind(dim_standardize(cru_index(0:60),1) .lt. -1)
;positive_wpa=ind(dim_standardize(cru_index(0:60),1) .gt. 1)
;negative_wpa=ind(dim_standardize(cru_index(0:60),1) .lt. -1)
;positive_epa=ind(dim_standardize(cru_index(0:60),1) .gt. 1)
;negative_epa=ind(dim_standardize(cru_index(0:60),1) .lt. -1)

;pos_winblk=new(4,"float")
;neg_winblk=new(4,"float")
pos_eur=dim_sum_n(dur_eur(:,positive_atl),1);/(sum(dur_eur)*1.0)
neg_eur=dim_sum_n(dur_eur(:,negative_atl),1);/(sum(dur_eur)*1.0)
pos_wpa=dim_sum_n(dur_wpa(:,positive_wpa),1);/(sum(dur_wpa)*1.0)
neg_wpa=dim_sum_n(dur_wpa(:,negative_wpa),1);/(sum(dur_wpa)*1.0)
pos_epa=dim_sum_n(dur_epa(:,positive_wpa),1);/(sum(dur_epa)*1.0)
neg_epa=dim_sum_n(dur_epa(:,negative_wpa),1);/(sum(dur_epa)*1.0)
pos_atl=dim_sum_n(dur_atl(:,positive_atl),1);/(sum(dur_atl)*1.0)
neg_atl=dim_sum_n(dur_atl(:,negative_atl),1);/(sum(dur_atl)*1.0)
print(pos_atl)
print(neg_atl)
print(pos_eur)
print(neg_eur)
print(pos_wpa)
print(neg_wpa)
print(pos_epa)
print(neg_epa)
end








