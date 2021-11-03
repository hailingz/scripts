load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "~/lib/advance_cymdh.ncl"
load "~/lib/attache_labelbar.ncl"


; if multiple missions to be plotted in the same panel or not;
plot_multi_mission = 1   ; 1 means in same panel, 0 on seperate panels
; if multiple missions to be plotted in the same panel or not;

;;;;;;;;;; plotting obs locations by QC tyopes;;;;;;
layout  = 6
nfile   = stringtointeger(layout^3)
DATADir = "/work2/noaa/da/hailingz/work/newinstru//run/test/"
fmt     =  "gnssro_output"
outfig  = "x11"

;;;; EDIT YOUR SELECTION of satellites and satellite id ;;;;
missions   = (/"  C2", "  K5"/)
nmis       = dimsizes(missions)
satid      = new ((/2,nmis/),integer)
satid(0,0) = 750
satid(1,0) = 755
satid(0,1) = 825
satid(1,1) = 825
;;;; EDIT YOUR SELECTION of satellites and satellite id ;;;;
 

;;;;;; preference of lines;;;;;;;;;
colors_mis    = (/"black", "red", "blue", "darkgreen"/)
;;;;;; preference of lines;;;;;;;;;

 
;;;; EDIT YOUR SELECTION OF TIME(s) TO PLOT;;;;;
  ;; BY giving start and endtime;;
    starttime =  "2021011000"
    endtime   =  "2021011000"
    valid_date  = starttime
    ntime       = 0
    do while ( valid_date .le. endtime )
       ntime = ntime + 1
       valid_date = advance_cymdh(valid_date,6)
    end do
   ; ---------------------------
;;;; EDIT YOUR SELECTION OF TIME(s) TO PLOT;;;;;
  ;; BY giving starttime and count of times;;
   ; starttime = 2021011000
   ; ntime     = 1
   ; endtime = systemfunc("~/lib/da_advance_time.exe " + starttime + " " + (ntime-1)*6)
;;;; EDIT YOUR SELECTION OF TIME(s) TO PLOT;;;;;


;;;; EDIT vertical bin/interval for statistics ;;;;
vintfix        = 1       ; the interval in km for statistics
vmax           = 50.0    ; top of bins
vmin           = 0       ; bottom of bins
;;;; EDIT vertical bin/interval for statistics ;;;;
max_level   = floattoint (( vmax - vmin ) /vintfix  +1) ; 51
levels      = new (max_level, float)
levels      = fspan(0.0, vmax, max_level)
nlevels     = dimsizes(levels)

wks     = gsn_open_wks(outfig, "statistic_omb_obscount_byMission_"+starttime+"_"+endtime) 
gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200"); 

tob  = new((/nmis,max_level/), float)
rms  = new((/nmis,max_level/), float)
bias = new((/nmis,max_level/), float)
bias = 0
rms  = 0
tob  = 0

do it = 0, ntime - 1

   anatime = systemfunc("~/lib/da_advance_time.exe " + starttime + " " + it*6)
   files   = systemfunc("ls "+ DATADir+anatime+"/output/hofx/"+fmt+"_"+anatime+"_0*.nc4")
   nfile   = dimsizes(files)
   do iff = 50, 100;nfile - 1
      f0 = addfile(files(iff),"r")
      g0  =  f0=>/MetaData
      g1  =  f0=>/hofx
      g2  =  f0=>/ObsValue
      g3  =  f0=>/EffectiveQC
      eqc =  g3->bending_angle
      obs =  g2->bending_angle
      hox =  g1->bending_angle
      sid =  g0->occulting_sat_id
      imh =  g0->impact_height
      imh = imh/1000.0

      do k = 1, nlevels - 1 ;  vertical bin loop
         do is = 0, nmis - 1 ; satellite id loop
          
            ind0 = ind( imh.ge.levels(k-1) .and.imh.lt.levels(k) .and. eqc.eq.0 .and.( sid.ge.satid(0,is).and.sid.le.satid(1,is)))
            if(.not.ismissing(ind0(0))) then
              depart = ( obs(ind0)-hox(ind0)) /hox(ind0)
              rms(is,k)  = sqrt( (rms(is,k)^2*tob(is,k)+sum( depart^2))/(dimsizes(ind0)+tob(is,k)))
              bias(is,k) = (bias(is,k)*tob(is,k)+sum( depart) )/(dimsizes(ind0)+tob(is,k))
              tob(is,k)  = tob(is,k) + dimsizes(ind0)
              delete([/depart/])
            end if
            delete([/ind0/])
         end do
      end do

      delete([/f0,eqc,sid,hox,obs,imh/])
      delete([/g0,g1,g2,g3/])
   end do
end do
rms  = where( rms.eq.0.0, rms@_FillValue, rms*100)
bias = where(bias.eq.0.0,bias@_FillValue, bias*100)

;jj = 0.0
;do while ( max(tob).ge.10.0 )
;   tob=tob/10.0
;   jj=jj+1
;end do

res          = True
res@gsnDraw  = False
res@gsnFrame = False
res@tmBorderThicknessF       = 1.0;
res@tmXBMajorThicknessF      = res@tmBorderThicknessF
res@tmYLMajorThicknessF      = res@tmBorderThicknessF

res@vpXF               = 0.04;
res@vpYF               = 0.75;
res@vpHeightF          = 0.5
res@vpWidthF           = 0.35
res@tiXAxisFontHeightF = 0.017
res@tiYAxisFontHeightF = 0.017
res@tmYLMajorOutwardLengthF     =  0.0; 
res@tmYLMajorLengthF            =  0.01
res@tmYLMinorOutwardLengthF     =  0.0; 
res@tmXBMajorOutwardLengthF     =  0.0; 
res@tmXBMinorOutwardLengthF     =  0.0; 
res@tmYLLabelFontHeightF        = 0.015
res@tmXBLabelFontHeightF        = 0.015

res@trYMaxF                = vmax
res@trYMinF                = 0.
res@pmLegendParallelPosF   = 0.67
res@pmLegendOrthogonalPosF = -0.95
res@pmLegendWidthF         = 0.03*nmis
res@pmLegendHeightF        = 0.065
res@lgLabelFontHeightF     = .015                   ; change font height
res@lgPerimOn              = False                 ; no box around 
res@pmLegendDisplayMode    = "Always"
res@lgJustification        = "TopLeft"

res@tmXBMode              = "Manual"
res@tmXTMode              = "Manual"
res@tiYAxisString         = "Impact height (km)"

res@xyDashPattern          = 0
res@tmXBPrecision          = 1
res@xyLineThicknesses      = 1.5
resc = res
resc@trXMinF             = 0.0
resc@pmLegendDisplayMode = "Never"
resc@xyDashPatterns      = (/2,2,2,2,2/)
resc@gsnLeftStringFontHeightF  = 0.015

resrms  = res
resrms@tiXAxisString            = "(O-B)/B rms (%)"
resrms@trXMaxF                 = 15.0
resrms@trXMinF                 = 0.0
resrms@tmXBTickSpacingF        = 3.
resrms@tmXBPrecision           = 2
resbias = res
resbias@tiXAxisString           = "(O-B)/B mean (%)"
resbias@gsnXRefLine             = 0
resbias@gsnXRefLineDashPattern  = 0
resbias@gsnXRefLineThicknessF   = 1.0
resbias@trXMaxF                 = 9.0
resbias@trXMinF                 = -9.0
resbias@tmXBTickSpacingF        = 3.
resbias@tmXBPrecision           = 1
if (plot_multi_mission .eq. 1) then
  nplt  = 1
else
  nplt  = nmis  
end if
plot   = new(nplt*2,graphic)

if (plot_multi_mission .eq. 1) then
   jj = 0.0
   do while ( max(tob).ge.10.0 )
     tob=tob/10.0
     jj=jj+1
   end do
   resc@gsnLeftString      = "obs count (10~N~~S~"+jj+"~N~)"
   resc@xyLineColors       = colors_mis
   resrms@xyLineColors     = colors_mis
   resbias@xyLineColors    = resrms@xyLineColors
   resrms@xyExplicitLegendLabels  =  missions
   resbias@xyExplicitLegendLabels =  missions
   plot(0)  = gsn_csm_x2y (wks, rms,tob,levels, resrms,resc)
   plot(1)  = gsn_csm_x2y (wks,bias,tob,levels,resbias,resc)
else 
   do is = 0, nmis - 1
      jj = 0.0
      do while ( max(tob(is,:)).ge.10.0 )
         tob(is,:)=tob(is,:)/10.0
         jj=jj+1
      end do
      resc@trXMaxF             = max(tob(is,:))*1.01
      if (resc@trXMaxF .lt. 2) then
         resc@tmXTPrecision          = 2
      else
         resc@tmXTPrecision          = 1
         resc@tmXTTickSpacingF       = 1.
      end if
      resc@gsnLeftString            = "obs count (10~N~~S~"+jj+"~N~)"
      resc@xyLineColors             = colors_mis(is)
      resrms@xyLineColors           = colors_mis(is)
      resbias@xyLineColors          = resrms@xyLineColors 
      resrms@xyExplicitLegendLabels =  missions(is)
      resbias@xyExplicitLegendLabels=  missions(is)
      plot(is*2)   = gsn_csm_x2y (wks, rms(is,:),tob(is,:),levels,resrms, resc)
      plot(is*2+1) = gsn_csm_x2y (wks,bias(is,:),tob(is,:),levels,resbias,resc)
   end do 
end if

resP = True
resP@txFontHeightF = 0.018
resP@txString      = " BA statistics by missions " +starttime+"-"+endtime
gsn_panel(wks,plot,(/nplt,2/),resP)

