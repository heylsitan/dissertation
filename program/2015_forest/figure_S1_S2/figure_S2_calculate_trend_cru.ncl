;;Usage: trend
;;Author: Heyl 20150213
;;rewrite on 20150826
path="./"
f=addfile(path+"table1_cru_cold_warm.nc","r")

t_nh_ann=f->t_nh_ann
t_nh_warm=f->t_nh_warm
t_nh_cold=f->t_nh_cold

t_siberia_ann=f->t_siberia_ann
t_siberia_warm=f->t_siberia_warm
t_siberia_cold=f->t_siberia_cold

year=ispan(1901,2013,1)

trend_nh_ann_98=regCoef(year(97:111),t_nh_ann(97:111))
trend_nh_ann_70=regCoef(year(69:96),t_nh_ann(69:96))
trend_siberia_ann_98=regCoef(year(97:111),t_siberia_ann(97:111))
trend_siberia_ann_70=regCoef(year(69:96),t_siberia_ann(69:96))

trend_nh_warm_98=regCoef(year(97:111),t_nh_warm(97:111))
trend_nh_warm_70=regCoef(year(69:96),t_nh_warm(69:96))
trend_siberia_warm_98=regCoef(year(97:111),t_siberia_warm(97:111))
trend_siberia_warm_70=regCoef(year(69:96),t_siberia_warm(69:96))

trend_nh_cold_98=regCoef(year(97:111),t_nh_cold(97:111))
trend_nh_cold_70=regCoef(year(69:96),t_nh_cold(69:96))
trend_siberia_cold_98=regCoef(year(97:111),t_siberia_cold(97:111))
trend_siberia_cold_70=regCoef(year(69:96),t_siberia_cold(69:96))

;printVarSummary(trend_nh_ann_98)
system("rm trend_cru.nc")
fout=addfile("trend_cru.nc","c")
fout->trend_nh_ann_98=trend_nh_ann_98
fout->trend_nh_ann_70=trend_nh_ann_70
fout->trend_siberia_ann_98=trend_siberia_ann_98
fout->trend_siberia_ann_70=trend_siberia_ann_70
fout->trend_nh_warm_98=trend_nh_warm_98
fout->trend_nh_warm_70=trend_nh_warm_70
fout->trend_siberia_warm_98=trend_siberia_warm_98
fout->trend_siberia_warm_70=trend_siberia_warm_70
fout->trend_nh_cold_98=trend_nh_cold_98
fout->trend_nh_cold_70=trend_nh_cold_70
fout->trend_siberia_cold_98=trend_siberia_cold_98
fout->trend_siberia_cold_70=trend_siberia_cold_70

df1=trend_nh_ann_70@nptxy-2
tval1=trend_nh_ann_70@tval
prob1=betainc(df1/(df1+tval1^2),df1/2.0,0.5)
df2=trend_siberia_ann_70@nptxy-2
tval2=trend_siberia_ann_70@tval
prob2=betainc(df2/(df2+tval2^2),df2/2.0,0.5)
df3=trend_nh_ann_98@nptxy-2
tval3=trend_nh_ann_98@tval
prob3=betainc(df3/(df3+tval3^2),df3/2.0,0.5)
df4=trend_siberia_ann_98@nptxy-2
tval4=trend_siberia_ann_98@tval
prob4=betainc(df4/(df4+tval4^2),df4/2.0,0.5)

df5=trend_nh_warm_70@nptxy-2
tval5=trend_nh_warm_70@tval
prob5=betainc(df5/(df5+tval5^2),df5/2.0,0.5)
df6=trend_siberia_warm_70@nptxy-2
tval6=trend_siberia_warm_70@tval
prob6=betainc(df6/(df6+tval6^2),df6/2.0,0.5)
df7=trend_nh_warm_98@nptxy-2
tval7=trend_nh_warm_98@tval
prob7=betainc(df7/(df7+tval7^2),df7/2.0,0.5)
df8=trend_siberia_warm_98@nptxy-2
tval8=trend_siberia_warm_98@tval
prob8=betainc(df8/(df8+tval8^2),df8/2.0,0.5)
df9=trend_nh_cold_70@nptxy-2
tval9=trend_nh_cold_70@tval
prob9=betainc(df9/(df9+tval9^2),df9/2.0,0.5)
df10=trend_siberia_cold_70@nptxy-2
tval10=trend_siberia_cold_70@tval
prob10=betainc(df10/(df10+tval10^2),df10/2.0,0.5)
df11=trend_nh_cold_98@nptxy-2
tval11=trend_nh_cold_98@tval
prob11=betainc(df11/(df11+tval11^2),df11/2.0,0.5)
df12=trend_siberia_cold_98@nptxy-2
tval12=trend_siberia_cold_98@tval
prob12=betainc(df12/(df12+tval12^2),df12/2.0,0.5)
print(prob1)
print(prob2)
print(prob3)
print(prob4)
print(prob5)
print(prob6)
print(prob7)
print(prob8)
print(prob9)
print(prob10)
print(prob11)
print(prob12)
