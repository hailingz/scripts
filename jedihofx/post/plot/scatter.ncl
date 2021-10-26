load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "~/lib//advance_cymdh.ncl"

;;;;;;; figure format
outfig = "png"

;;;;;;; set up plotting period ;;;;;;;;;;;;;;;
starttime       = "2020121500"
endtime         = "2020121500"
;;;;;;; set up plotting period ;;;;;;;;;;;;;;;

;;;;;;; set up your test run hofx results ;;;;;;;;;;;;;
DIAGDIR="./hofx/"
;;;;;;; set up your test run hofx results ;;;;;;;;;;;;;

valid_date      = starttime
nt  = 0
do while ( valid_date .le. endtime )
      nt = nt + 1
      valid_date = advance_cymdh(valid_date,6)
end do

nobs    = 1000000
imh     = new(nobs, float)
lat     = new(nobs, float)
ben     = new(nobs, float)
qc0     = new(nobs, integer)
hox     = new(nobs, float)
gsihofx = new(nobs, float)


plot  = new(4,graphic)
wks   = gsn_open_wks (outfig,"hofx_scatters_ctest_omb_vs_gsidiag_vs_obs_"+starttime+"_"+endtime)
res                   = True
res@gsnDraw  = False
res@gsnFrame = False
res@tmBorderThicknessF       =   1.0;
res@tmXBMajorThicknessF      = res@tmBorderThicknessF
res@tmYLMajorThicknessF      = res@tmBorderThicknessF

res@vpXF               = 0.04;
res@vpYF               = 0.75;
res@vpHeightF          = 0.5
res@vpWidthF           = 0.5
res@tiXAxisFontHeightF = 0.02
res@tiYAxisFontHeightF = 0.02
res@tmYLMajorOutwardLengthF     =  0.0;
res@tmYLMajorLengthF            =  0.01
res@tmYLMinorOutwardLengthF     =  0.0;
res@tmXBMajorOutwardLengthF     =  0.0;
res@tmXBMinorOutwardLengthF     =  0.0;
res@tmYLLabelFontHeightF        = 0.02
res@tmXBLabelFontHeightF        = 0.022
res@tmXMajorGrid                = True
res@tmXMajorGridThicknessF      = 0.3
res@tmXMajorGridLineDashPattern = 2

res@tmYMajorGrid                = True
res@tmYMajorGridThicknessF      = 0.3
res@tmYMajorGridLineDashPattern = 2

res@xyMarkers          =  5                      ; choose type of marker
res@xyMarkerSizeF      = 0.001                       ; Marker size (default 0.01)
res@xyMarkerThicknessF = 0.7
res@xyMarkLineModes    = "Markers"
res@xyMarkerColor      = "black"
res@gsnLeftStringFontHeightF  = 0.022
res@gsnXRefLine  = 0.
res@gsnYRefLine  = 0.
res@gsnYRefLineDashPattern = 0
res@gsnYRefLineThicknessF  = 2
res@gsnYRefLineColor = "blue"
res@gsnLeftString      = " "
tobs = 0
do it = 0, nt -1
   nobs = 0
   anatime = systemfunc("~/lib/da_advance_time.exe "+ starttime+"  "+6*(it) )
   ftiles0 = systemfunc("ls "+ DIAGDIR+"gnssro_bndnbam_"+starttime+"_output_0*.nc4")
   nfile   = dimsizes(ftiles0)

   do i = 0, nfile - 1
      f0 = addfile(ftiles0(i),"r")
g0  =  f0=>/MetaData
g1  =  f0=>/hofx
g2  =  f0=>/ObsValue
g3  =  f0=>/PreQC
g4  =  f0=>/GsiHofX
imh0  = (g0->impact_height)/1000.0
nn=dimsizes(imh0)
      imh(nobs:nobs+nn-1)   = imh0
ben(nobs:nobs+nn-1)  =  g2->bending_angle
gsihofx(nobs:nobs+nn-1)  =  g4->bending_angle
hox(nobs:nobs+nn-1)  =  g1->bending_angle
;sid(nobs:nobs+nn-1)  =  g0->occulting_sat_id
qc0(nobs:dimsizes(imh0)+nobs-1)   = g3->bending_angle
lat(nobs:dimsizes(imh0)+nobs-1)   = g0->latitude
      nobs=dimsizes(imh0) + nobs 
      delete([/imh0,f0/])
   end do; tile loop at each time

   delete([/ftiles0/])
   tobs = tobs + nobs

   hox_qc = hox(0:nobs-1)
   hox_qc = where(qc0(0:nobs-1) .eq. 0, hox(0:nobs-1), hox@_FillValue)
   ben(0:nobs-1) = where(qc0(0:nobs-1) .eq. 0, ben(0:nobs-1), ben@_FillValue)
   gsihofx(0:nobs-1) = where(qc0(0:nobs-1) .eq. 0, gsihofx(0:nobs-1), gsihofx@_FillValue)
   omg_qc = (ben(0:nobs-1) - gsihofx(0:nobs-1) )/ben(0:nobs-1)*100.0
   omj_qc = (ben(0:nobs-1) - hox_qc )/ben(0:nobs-1)*100.0
   jmg_qc = (hox_qc-gsihofx(0:nobs-1) )/gsihofx(0:nobs-1)*100.0

   res@gsnLeftString      = " "
   res@trYMaxF       = 40.
   res@trYMinF       = -40.
   res@trXMaxF       = res@trYMaxF
   res@trXMinF       = 0
   res@tmYLTickSpacingF = 20.
 if ( it .eq. 0) then
     res@gsnLeftString      = "Gsi diag vs. obs"
     res@tiYAxisString      = "( obs - Gsi )/obs x100 (%)"
     res@tiXAxisString      = "Observation ( 10~S~-3~N~ rad ) "
     plot(0)  = gsn_csm_xy (wks,ben(0:nobs-1)*1000.0,omg_qc,res)
     res@gsnLeftString      = "Jedi hofx vs. obs"
     res@tiYAxisString      = "( obs - Jedi )/obs x100 (%)"
     plot(1)  = gsn_csm_xy (wks,ben(0:nobs-1)*1000.0,omj_qc,res)
   else
     plot0a = gsn_csm_xy (wks,ben(0:nobs-1)*1000.0,omg_qc,res)
     plot1a = gsn_csm_xy (wks,ben(0:nobs-1)*1000.0,omj_qc,res)
     overlay (plot(1), plot1a)
     overlay (plot(0), plot0a)
   end if

   res@trYMinF       = 0
   if ( it .eq. 0) then
     res@gsnLeftString      = "Jedi hofx vs Gsi diag"
     res@tiXAxisString      = "Gsi diag ( 10~S~-3~N~ rad ) "
     res@tiYAxisString      = "Jedi hofx ( 10~S~-3~N~ rad )"
     plot(2)  = gsn_csm_xy (wks,gsihofx(0:nobs-1)*1000.0,hox_qc*1000.0,res)
   else
     plot2a = gsn_csm_xy (wks,gsihofx(0:nobs-1)*1000.0,hox_qc*1000.0,res)
     overlay (plot(2), plot2a)
   end if
 res@trYMaxF       = 0.1
   res@trYMinF       = -0.1
   res@tmYLTickSpacingF          =  0.05
   res@tmYLPrecision          = 2
   res@tmYLMode              = "Manual"
   if ( it .eq. 0) then
     res@gsnLeftString      = "Jedi hofx vs Gsi diag"
     res@tiXAxisString      = "Gsi diag ( 10~S~-3~N~ rad ) "
     res@tiYAxisString      = "( Jedi - Gsi )/Gsi x100 (%)"
     plot(3)  = gsn_csm_xy (wks,gsihofx(0:nobs-1)*1000.0,jmg_qc,res)
   else
     plot3a = gsn_csm_xy (wks,gsihofx(0:nobs-1)*1000.0,jmg_qc,res)
     overlay (plot(3), plot3a)
   end if

end do
resP= True
resP@txString           = "JEDI NBAM vs GSI diag "+starttime+" - "+endtime+"  obs#="+tobs
gsn_panel(wks,plot,(/2,2/),resP)
exit


