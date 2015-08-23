;;Usage: plot eof first two mode (spatial and time series) 
;;Author: Heyl rewriten on 20150822

pathin="/home/yongli/yongli/dissertation/data/ncep/"
pathout="/home/yongli/yongli/dissertation/picture/2014-CD/figure1/"

; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latS   =  20.
  latN   =  80. 
  lonL   = -180.
  lonR   =  180.

  yrStrt = 1948
  yrLast = 2010

  season = "OND"    ; choose Dec-Jan-Feb seasonal mean

  neof   = 3        ; number of EOFs
  optEOF = True       
  optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

  optETS = False

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
  f      = addfile (pathin+"ncep_hgt_1948_2012.nc", "r")

  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  iYYYY  = iYYYY+2
  hgt    = f->hgt(iYYYY,5,:,:)
  printVarSummary(hgt)                              ; variable overview

; ==============================================================
; dataset longitudes span 0=>357.5
; Because EOFs of the North Atlantic Oscillation are desired
; use the "lonFlip" (contributed.ncl) to reorder 
; longitudes to span -180 to 177.5: facilitate coordinate subscripting
; ==============================================================
  hgt    = lonFlip( hgt )
  printVarSummary(hgt)                              ; note the longitude coord

; ==============================================================
; compute desired global seasonal mean: month_to_season (contributed.ncl) 
; ==============================================================
  HGT    = month_to_season (hgt, season)
  nyrs   = dimsizes(HGT&time)
  printVarSummary(HGT)
season="DJF"
; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
  rad    = 4.*atan(1.)/180.
  clat   = f->lat           
  clat   = sqrt( cos(rad*clat) )                 ; gw for gaussian grid

print(clat(0:10))
; =================================================================
; weight all observations 
; =================================================================
  wHGT   = HGT                                   ; copy meta data
  wHGT   = HGT*conform(HGT, clat, 1)
  wHGT@long_name = "Wgt: "+wHGT@long_name

; =================================================================
; Reorder (lat,lon,time) the *weighted* input data
; Access the area of interest via coordinate subscripting
; =================================================================
  x      = wHGT({lat|latS:latN},{lon|lonL:lonR},time|:)
  eof    = eofunc_Wrap(x, neof, optEOF)      
  eof_ts = eofunc_ts_Wrap (x, eof, optETS)

  printVarSummary( eof )                         ; examine EOF variables
  printVarSummary( eof_ts )
; print(eof_ts(0,0:10))
; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
  dimx   = dimsizes( x )
  mln    = dimx(1)
  sumWgt = mln*sum( clat({lat|latS:latN}) )
  eof_ts = eof_ts/sumWgt
;  print(sum(clat({lat|latS:latN})))
;;;output eof
system("/bin/rm -f "+pathin+"eof_hgt_ncep_2014CD.nc")
fout=addfile(pathin+"eof_hgt_ncep_2014CD.nc","c")
fout->eof=eof
fout->eof_ts=eof_ts
; =================================================================
; Extract the YYYYMM from the time coordinate 
; associated with eof_ts [same as HGT&time] 
; =================================================================

  yyyymm = cd_calendar(eof_ts&time,-2)/100  
;;yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0); not used here

;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks("eps",pathout+"eof_ncep_hgt_ce")
  gsn_define_colormap(wks,"BlWhRe")       ; choose colormap
  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
; EOF patterns

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

;---This resource not needed in V6.1.0
  res@gsnSpreadColors      = True         ; spread out color table

  res@gsnAddCyclic         = False        ; plotted dataa are not cyclic
 
  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
 ;res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's
  
  res@gsnAddCyclic         = True
                                          ; set symmetric plot min/max
  symMinMaxPlt(eof, 16, False, res)       ; contributed.ncl

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@lbLabelAutoStride   = True         ; auto stride on labels

  yStrt                    = yyyymm(0)/100
  yLast                    = yyyymm(nyrs-1)/100
  resP@txString            = "HGT: "+season+": "+yStrt+"-"+yLast

;*******************************************
; first plot
;*******************************************

; lon is -180 .. 177.5 so there is a cap in polar graphic, need add a row
;  eof2   = eof(lon|:,lat|:,evn|:)
;  eof3   = array_append_record(eof2,eof2(0,:,:),0)
;  eof4   = eof3(evn|:,lat|:,lon|:)
;  eof4&lon=fspan(-180,180,145)
  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
    plot(n)=gsn_csm_contour_map_ce(wks,eof(n,:,:),res)
;     plot(n)=gsn_csm_contour_map_polar(wks,eof(n,:,:),res)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
; EOF time series  [bar form]

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               

; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot


  rts@tiYAxisString = "Pa"                    ; y-axis label      

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnXYBarChart         = True            ; create bar chart 
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
  rts@xyLineColors          = (/"red","blue"/)    ; line around bar color

; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
  rtsP@txString             = "HGT: "+season+": "+yStrt+"-"+yLast

  year = yyyymm/100
;printVarSummary(year)
;print(eof_ts)
; create individual plots
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)     ; now draw as one plot



