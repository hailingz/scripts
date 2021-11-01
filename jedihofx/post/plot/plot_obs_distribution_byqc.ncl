load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "~/lib/advance_cymdh.ncl"
load "~/lib/attache_labelbar.ncl"

;;;;;;;;;; plotting obs locations by QC tyopes;;;;;;
layout  = 6
nfile   = stringtointeger(layout^3)
DATADir = "/work2/noaa/da/hailingz/work/newinstru//run/test/"
fmt     =  "gnssro_output"
outfig  = "png"
;;;; EDIT YOUR SELECTION OF TIME(s) TO PLOT;;;;;
  ;; BY giving start and endtime;;
   ; starttime = 
   ; endtime   =
   ; valid_date      = starttime
   ; ntime  = 0
   ; do while ( valid_date .le. endtime )
   ;    ntime = ntime + 1
   ;    valid_date = advance_cymdh(valid_date,6)
   ; end do
   ; ---------------------------
;;;; EDIT YOUR SELECTION OF TIME(s) TO PLOT;;;;;
  ;; BY giving starttime and count of times;;
    starttime = 2021011000
    ntime     = 1
    endtime = systemfunc("~/lib/da_advance_time.exe " + starttime + " " + (ntime-1)*6)
;;;; EDIT YOUR SELECTION OF TIME(s) TO PLOT;;;;;

wks     = gsn_open_wks(outfig, "RO_location_byqc_"+starttime+"_"+endtime) 
gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200"); 

mpres         = True
mpres@mpOutlineOn           = False;True
mpres@mpDataBaseVersion     = "LowRes"
mpres@vpHeightF             = 0.5    ; Width and height of
mpres@vpWidthF              = 0.82;   
mpres@tmYLTickSpacingF         = 30;
mpres@tmXBTickSpacingF         = 60;
mpres@tmYLMajorOutwardLengthF  = 0.0;
mpres@tmYLMinorOutwardLengthF  = 0.0;
mpres@tmXBMajorOutwardLengthF  = 0.0;
mpres@tmXBMinorOutwardLengthF  = 0.0;
mpres@tmXBMajorLengthF         = 0.008;
mpres@tmYLMajorLengthF         = 0.008;
mpres@mpGridAndLimbOn          = False;  True
mpres@tmXBLabelFontHeightF     = 0.016
mpres@tmYLLabelFontHeightF     = 0.016
mpres@gsnDraw                  = False
mpres@gsnFrame                 = False
mpres@gsnLeftStringFontHeightF = 0.02;

dummy0 = new((/ntime,nfile/), "graphic")
dummy1 = new((/ntime,nfile/), "graphic")
dummy2 = new((/ntime,nfile/), "graphic")
plot   = new(3,graphic)

mkres  = True
colors = (/"black","blue", "red"/)

mpres@gsnLeftString    = " Assimialted obs: "; + sprintf("%5.2f",npass)+"%"
plot(0)  = gsn_csm_map(wks,mpres)
mpres@gsnLeftString    = "rejected by bkg departure check: "; + sprintf("%5.2f",nfail)+"%"
plot(1)  = gsn_csm_map(wks,mpres)
mpres@gsnLeftString    = "rejected by super refraction check: "; + sprintf("%5.2f",nsr)+"%"
plot(2)  = gsn_csm_map(wks,mpres)

npass = 0.
ndpt  = 0.
nsr   = 0.

do it = 0, ntime - 1

   anatime = systemfunc("~/lib/da_advance_time.exe " + starttime + " " + it*6)
   files   = systemfunc("ls "+ DATADir+anatime+"/output/hofx/"+fmt+"_"+anatime+"_0*.nc4")
   nfile   = dimsizes(files)
   do iff = 0, nfile - 1
      f0 = addfile(files(iff),"r")
      g0  =  f0=>/MetaData
      g1  =  f0=>/hofx
      g2  =  f0=>/ObsValue
      g3  =  f0=>/EffectiveQC
      g4  =  f0=>/SRflag
      lat = g0->latitude
      lon = g0->longitude
      pqc = g3->bending_angle
      sr  = g4->bending_angle

      mkres@gsMarkerSizeF = 0.0015
      mkres@gsMarkerIndex   = 16
      ind_id = ind(pqc.ne.15)
      if (.not.ismissing(ind_id(0))) then
         mkres@gsMarkerColor   = colors(0) 
         dummy0(it,iff) = gsn_add_polymarker(wks,plot(0),lon(ind_id),lat(ind_id),mkres)
         npass = npass + dimsizes(ind_id)
      end if
      delete([/ind_id/])

      mkres@gsMarkerSizeF = 0.0215
      mkres@gsMarkerIndex   = 5
      ind_id = ind(pqc.eq.19)
      if (.not.ismissing(ind_id(0))) then
         mkres@gsMarkerColor   = colors(1)
         dummy1(it,iff) = gsn_add_polymarker(wks,plot(1),lon(ind_id),lat(ind_id),mkres)
         ndpt=ndpt + dimsizes(ind_id) 
      end if
      delete([/ind_id/])

      ind_id = ind(sr.gt.0)
      if (.not.ismissing(ind_id(0))) then
         mkres@gsMarkerColor   = colors(2)
         dummy2(it,iff) = gsn_add_polymarker(wks,plot(2),lon(ind_id),lat(ind_id),mkres)
         nsr= nsr + dimsizes(ind_id)
      end if
      delete([/ind_id/])

      delete([/f0,lat,lon,pqc,sr/])
      delete([/g0,g1,g2,g3,g4/])
   end do
end do

ntot  = npass + ndpt + nsr
npass = npass/ntot*100.0
ndpt  = ndpt/ntot*100.0
nsr   = nsr/ntot*100.

txres = True
txres@txFontHeightF        =  0.013; mpres@gsnLeftStringFontHeightF
gsn_text_ndc(wks,"         "+sprintf("%5.2f",npass)+"%" ,0.4,0.933,txres) 
gsn_text_ndc(wks,"                                                       "+sprintf("%5.2f",ndpt)+"%" ,0.4,0.623,txres)
gsn_text_ndc(wks,"                                                            "+sprintf("%5.2f",nsr)+"%" ,0.4,0.308,txres)

resP = True
resP@txFontHeightF = 0.017
resP@txString      = " obs locations by QC " +starttime+"-"+endtime
gsn_panel(wks,plot,(/3,1/),resP) 
exit
