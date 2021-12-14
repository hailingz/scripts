load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;;;;; see fig_tmp_levelmean_2021010406.pdf for reference;;;

variable  = "tmp"; variable to plot
outfig    = "pdf" ; plot format

;;;; EDIT YOUR analysis time for increment plot;;;
anatime    = "2021010406"
assim_freq = 6
hh         = systemfunc("echo "+anatime+" |cut -c9-10")

;;;;;;;;;; EDIR directories
TOPDir  = "hui"
DATADir = "/work/noaa/da/hailingz/work/"+TOPDir+"/run/ctrl/"
; forecast initilization time
init_time = systemfunc("/home/hailingz/lib/da_advance_time.exe " + anatime + " -" +assim_freq)
hh_init   = systemfunc("echo "+init_time+" |cut -c9-10")
; files
bkgfile   = addfile(DATADir+init_time+"/atmos/gdas.t"+hh_init+"z.atmf006.nc", "r")
anafile   = addfile(DATADir+anatime+"/atmos/gdas.t"+hh+"z.atmf000.nc", "r")

;;;; variable index in files  ;;;;;;;;
vnamebkg    = getfilevarnames(bkgfile)
vnameana    = getfilevarnames(anafile)
varindxbkg  = ind(vnamebkg.eq.variable)
varindxana  = ind(vnameana.eq.variable)

bkg      = bkgfile->$vnamebkg(varindxbkg)$(0,:,:,:)
ana      = anafile->$vnameana(varindxana)$(0,:,:,:)
bkgavg   = dim_avg_n(bkg,(/1,2/))
anaavg   = dim_avg_n(ana,(/1,2/))
;;;; coordinate ;;;;;;;
pfull   = bkgfile->pfull

wks     = gsn_open_wks(outfig, "fig_"+variable+"_levelmean_"+anatime) 

res = True
res@vpXF          = 0.25;
res@vpYF          = 0.85;
res@vpWidthF      = 0.45 ;
res@vpHeightF     = 0.7
res@gsnDraw       = False
res@gsnFrame      = False
; lines
res@xyLineThicknessF       = 1.9
; model levels as vertical coordinate
levels         = ispan(1,dimsizes(pfull),1 )
res@trYMinF    = levels(0)       			; set Y-axis min
res@trYMaxF    =  levels(dimsizes(levels)-1)
res@tmYLMode   = "Explicit"
; yaxis using model levels
res@tmYLValues = levels(::4)
res@tmYLLabels = levels(::4)
res@tmYLMajorOutwardLengthF     =  0.00;
res@tmYLMinorValues             = levels
res@tmYLMinorOutwardLengthF     =  0.00;
res@tmYLLabelFontHeightF        = 0.016;
; yaxis using reference pressure
res@tmYRLabelsOn            = True           ; turn on right axis labels
res@tmYUseLeft              = False          ; don't use any left settings
res@tmYRMode                = "Explicit"
res@tmYRPrecision           = 4              ; set the precision  
res@tmYRValues              = res@tmYLValues
res@tmYRLabels              = sprintf("%5.1f",pfull(::4))
res@trYReverse              = True
res@tmYRMajorOutwardLengthF =  0.00;
res@tmYRMinorOutwardLengthF =  0.00;
res@tmYRMinorValues         = levels
res@tmYRLabelFontHeightF    = res@tmYLLabelFontHeightF 
; reference line x=0
res@gsnXRefLine             = 0
res@gsnXRefLineDashPattern  = 2
res@gsnXRefLineThicknessF   = 2.0
; xaxis
res@tmXBMajorOutwardLengthF =  0.00;
res@tmXBMinorOutwardLengthF =  0.00;
res@tmXBPrecision           = 1
;;; axises and title ;;;
res@tiXAxisFontHeightF    = 0.017
res@tiYAxisFontHeightF    = 0.017
res@tiXAxisString         = "increment ("+bkg@units+")"
res@tiYAxisString         = "Model Level"
txres = True                                   ; draw YR-axis title
txres@txFontHeightF  = res@tiYAxisFontHeightF   ; set the font height to the YL Axis Font Height
txres@txAngleF       = -90                      ; rotate the title -90 degrees
gsn_text_ndc(wks,"Reference Pressure (hPa)",0.8,.5,txres)   ; draw the YR-axis title
res@gsnLeftStringFontHeightF    = 0.018
res@gsnLeftString               = "level averaged "+variable +" increment ("+bkg@units+") at " + anatime 
plot = gsn_csm_xy (wks, anaavg-bkgavg,levels,res)
draw(plot)
frame(wks)
