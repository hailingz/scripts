load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/home/hailingz/lib/advance_cymdh.ncl"
load "/home/hailingz/util/attache_labelbar.ncl"


;;; see statistic_omb_obscount_byMission_2021010406_2021010406.pdf for reference  ;;

; if multiple missions to be plotted in the same panel or not;
plot_multi_mission = 0   ; 1 means in same panel, 0 on seperate panels
; if multiple missions to be plotted in the same panel or not;

;;;;;;;;;; plotting obs locations by QC tyopes;;;;;;
layout  = 6
nfile   = stringtointeger(layout^2*6) 
DATADir = "/work/noaa/da/hailingz/work/hui/run/ctrl/"
fmt     =  "gnssro_NBAM"
outfig  = "pdf"

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
    starttime =  "2021010406"
    endtime   =  "2021010406"
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

tob  = new((/nmis,2,max_level/), float)
rms  = new((/nmis,2,max_level/), float)
bias = new((/nmis,2,max_level/), float)
bias = 0
rms  = 0
tob  = 0

do it = 0, ntime - 1

   anatime = systemfunc("~/lib/da_advance_time.exe " + starttime + " " + it*6)
   files   = systemfunc("ls "+ DATADir+anatime+"/3dhyb/output/hofx/"+fmt+"_"+anatime+"_0*.nc4")
   nfile   = dimsizes(files)
   do iff = 50, 100;nfile - 1
      f0 = addfile(files(iff),"r")
      g0  =  f0=>/MetaData
      g10  =  f0=>/hofx0
      g11  =  f0=>/hofx1
      g2   =  f0=>/ObsValue
      g30  =  f0=>/EffectiveQC0
      g31  =  f0=>/EffectiveQC1
      g40  =  f0=>/ombg
      g41  =  f0=>/oman
      qc0 =  g30->bending_angle
      qc1 =  g31->bending_angle
      obs =  g2->bending_angle
      hox0 =  g10->bending_angle
      hox1 =  g11->bending_angle
      oman =  g40->bending_angle
      ombg =  g41->bending_angle
      sid =  g0->occulting_sat_id
      imh =  g0->impact_height
      imh = imh/1000.0


      do k = 1, nlevels - 1 ;  vertical bin loop
         do is = 0, nmis - 1 ; satellite id loop
          
            ind0 = ind( imh.ge.levels(k-1) .and.imh.lt.levels(k) .and. qc0.eq.0 .and.( sid.ge.satid(0,is).and.sid.le.satid(1,is)))
            if(.not.ismissing(ind0(0))) then
              depart = ( obs(ind0)-hox0(ind0)) /hox0(ind0)
              rms(is,0,k)  = sqrt( (rms(is,0,k)^2*tob(is,0,k)+sum( depart^2))/(dimsizes(ind0)+tob(is,0,k)))
              bias(is,0,k) = (bias(is,0,k)*tob(is,0,k)+sum( depart) )/(dimsizes(ind0)+tob(is,0,k))
              tob(is,0,k)  = tob(is,0,k) + dimsizes(ind0)
              delete([/depart/])
            end if
            delete([/ind0/])

            ind0 = ind( imh.ge.levels(k-1) .and.imh.lt.levels(k) .and. qc1.eq.0 .and.( sid.ge.satid(0,is).and.sid.le.satid(1,is)))
            if(.not.ismissing(ind0(0))) then
              depart = ( obs(ind0)-hox1(ind0)) /hox1(ind0)
              rms(is,1,k)  = sqrt( (rms(is,1,k)^2*tob(is,1,k)+sum( depart^2))/(dimsizes(ind0)+tob(is,1,k)))
              bias(is,1,k) = (bias(is,1,k)*tob(is,1,k)+sum( depart) )/(dimsizes(ind0)+tob(is,1,k))
              tob(is,1,k)  = tob(is,1,k) + dimsizes(ind0) 
              delete([/depart/])
            end if
            delete([/ind0/])
         end do
      end do

      delete([/f0,qc0,qc1,sid,hox0,hox1,obs,imh/])
      delete([/ombg,oman/])
      delete([/g0,g10,g11,g2,g30,g31,g40,g41/])
   end do
end do
rms  = where( rms.eq.0.0, rms@_FillValue, rms*100)
bias = where(bias.eq.0.0,bias@_FillValue, bias*100)
tob  = where(tob.eq.0, tob@_FillValue, tob)

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
res@pmLegendParallelPosF   = 0.57
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

;res@xyDashPatterns         = (/0,16,2,2,2/)
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
resbias@trXMaxF                 = 6.0
resbias@trXMinF                 = -6.0
resbias@tmXBTickSpacingF        = 2.
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
   plot(0)  = gsn_csm_x2y (wks, rms(:,0,:),tob(:,0,:),levels, resrms,resc)
   plot(1)  = gsn_csm_x2y (wks,bias(:,0,:),tob(:,0,:),levels,resbias,resc)
else 
   do is = 0, nmis - 1
      jj = 0.0
      do while ( max(tob(is,0,:)).ge.10.0 )
         tob(is,0,:)=tob(is,0,:)/10.0
         jj=jj+1
      end do
      resc@trXMaxF             = max(tob(is,0,:))*1.01
      if (resc@trXMaxF .lt. 2) then
         resc@tmXTPrecision          = 2
      else
         resc@tmXTPrecision          = 1
         resc@tmXTTickSpacingF       = 1.
      end if
      resc@gsnLeftString            = "obs count (10~N~~S~"+jj+"~N~)"
      resc@xyLineColors             = colors_mis(is)
      resrms@xyLineColors           = colors_mis(is)
      resrms@xyDashPattern         = 0
      resbias@xyDashPattern         = 0
      resbias@xyLineColors          = resrms@xyLineColors 
      resrms@pmLegendOrthogonalPosF = -0.95
      resbias@pmLegendOrthogonalPosF = -0.95
      resrms@xyExplicitLegendLabels =  missions(is)+(/"_omb"/)
      resbias@xyExplicitLegendLabels=  missions(is)+(/"_omb"/)
      plot(is*2)   = gsn_csm_x2y (wks, rms(is,0,:),tob(is,0,:),levels,resrms, resc)
      plot(is*2+1) = gsn_csm_x2y (wks,bias(is,0,:),tob(is,0,:),levels,resbias,resc)
      resrms@xyDashPattern         = 16
      resbias@xyDashPattern         = 16
      resrms@pmLegendOrthogonalPosF = -0.88
      resbias@pmLegendOrthogonalPosF = -0.88
      resrms@xyExplicitLegendLabels =  missions(is)+(/"_oma"/)
      resbias@xyExplicitLegendLabels=  missions(is)+(/"_oma"/)
 ;     plota        = gsn_csm_xy (wks, rms(is,1,:),levels,resrms)
      plota   = gsn_csm_x2y (wks, rms(is,1,:),tob(is,1,:),levels,resrms, resc)
      plotb   = gsn_csm_x2y (wks,bias(is,1,:),tob(is,1,:),levels,resbias,resc)
      overlay(plot(is*2), plota)
      overlay(plot(is*2+1), plotb)
   end do  
end if

resP = True
resP@txFontHeightF = 0.018
resP@txString      = " BA statistics by missions " +starttime+"-"+endtime
gsn_panel(wks,plot,(/nplt,2/),resP)

