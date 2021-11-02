load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "~/lib/attache_labelbar.ncl"

starttime = 2021011000
DATADir   = "/work2/noaa/da/hailingz/work/newinstru/Data/ioda2/"
fmt       =  "gnssro_obs"
;;;;;;EDIT your choice of missions to plot here;;;
;select_id     = (/   750, 751, 752, 753, 754, 755, 825/)
select_id_str = (/"C2","Komp5","MetOp", "Other"/)
;;;;;;EDIT your choice of missions to plot here;;;

;;;;;; preference of markers;;;;;;;;;
colors_mis    = (/20,60,85,130/)
markers_mis   = (/15, 16,5,7/)
thick_mis     = (/1.5,1.5,4.0,2.0/)
;;;;;; preference of markers;;;;;;;;;

outfig        = "x11"
wks = gsn_open_wks(outfig, "RO_location_bymission_"+starttime)
gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200"); 


mpres         = True
mpres@mpOutlineOn        = True
mpres@mpDataBaseVersion  = "LowRes"
mpres@vpHeightF          = 0.85    ; Width and height of
mpres@vpWidthF           = 0.82;   
mpres@gsnDraw            = False
mpres@gsnFrame           = False
mpres@tmYLTickSpacingF         = 30;
mpres@tmXBTickSpacingF         = 60;
mpres@tmYLTickStartF           = 30 
mpres@tmYLMajorOutwardLengthF  =  0.0;
mpres@tmYLMinorOutwardLengthF  =  0.0;
mpres@tmXBMajorOutwardLengthF  =  0.0;
mpres@tmXBMinorOutwardLengthF  =  0.0;
mpres@tmXBMajorLengthF         =  0.008;
mpres@tmYLMajorLengthF         =  0.008;
mpres@mpGridAndLimbOn          = False;  True
mpres@tmXBLabelFontHeightF     = 0.016
mpres@tmYLLabelFontHeightF     = 0.016
mpres@mpLandFillColor          = -1
mpres@gsnLeftString            = "RO profile locations @"+starttime
mpres@gsnLeftStringFontHeightF = 0.02;

dummy = new((/40/),"graphic")
plot  = gsn_csm_map(wks,mpres)

f0  = addfile(DATADir+fmt+"_"+starttime+".nc4","r")
g0  =  f0=>/MetaData
lat =  g0->latitude
lon =  g0->longitude
rec =  g0->record_number
sid =  g0->occulting_sat_id

unique = get_unique_values(rec)

latu = new(dimsizes(unique), float)
lonu = new(dimsizes(unique), float)
sidu = new(dimsizes(unique), float)
do ii = 0 , dimsizes(unique) -1
   ind0 = ind( rec .eq. unique(ii))
   latu(ii) = lat(ind0(0))
   lonu(ii) = lon(ind0(0))
   sidu(ii) = sid(ind0(0))
   delete(ind0) 
end do

mkres = True
mkres@gsMarkerSizeF      = 0.007
mkres@gsMarkerThicknessF = 1.5

;;;;;;; plotting markers by satellite id;;;;;;;;; 
;;;;;     COSMIC2     ;;;;;
ind_id = ind(sidu.ge.750 .and. sidu.le.755)
if (.not.ismissing(ind_id(0))) then
    mkres@gsMarkerColor      = colors_mis(0)
    mkres@gsMarkerIndex      = markers_mis(0)
    mkres@gsMarkerThicknessF = thick_mis(0)
    dummy(0) = gsn_add_polymarker(wks,plot,lonu(ind_id),latu(ind_id),mkres)
end if 
delete([/ind_id/])


;;;;;   KOMPSAT5    ;;;;;
ind_id = ind(sidu.eq.825) 
if (.not.ismissing(ind_id(0))) then
    mkres@gsMarkerColor      = colors_mis(1)
    mkres@gsMarkerIndex      = markers_mis(1)
    mkres@gsMarkerThicknessF = thick_mis(1)
    dummy(1) = gsn_add_polymarker(wks,plot,lonu(ind_id),latu(ind_id),mkres)
end if
delete([/ind_id/])

;;;;;   MeTop      ;;;;;
ind_id = ind(sidu.ge.3 .and. sidu.le.5)
if (.not.ismissing(ind_id(0))) then
    mkres@gsMarkerColor      = colors_mis(2)
    mkres@gsMarkerIndex      = markers_mis(2)
    mkres@gsMarkerThicknessF = thick_mis(2)
    dummy(2) = gsn_add_polymarker(wks,plot,lonu(ind_id),latu(ind_id),mkres)
end if
delete([/ind_id/])

;;;;; other missions ;;;;;
ind_id = ind( (sidu.lt.750.or.sidu.gt.755) .and. sidu .ne.825 .and.sidu.gt.5)
if (.not.ismissing(ind_id(0))) then
    mkres@gsMarkerColor      = colors_mis(3)
    mkres@gsMarkerIndex  = markers_mis(3)
    mkres@gsMarkerThicknessF=thick_mis(3)
    dummy(3) = gsn_add_polymarker(wks,plot,lonu(ind_id),latu(ind_id),mkres)
end if 
delete([/ind_id/]) 

lbid = attach_labelbar(wks,plot,select_id_str,colors_mis, 0)

draw(plot)
frame(wks)
exit
