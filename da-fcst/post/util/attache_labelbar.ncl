function attach_labelbar(wks,plot,arr[*]:string,colors[*], center:integer)
local lbres, vph, vpw, nboxes
begin
  getvalues plot
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@lbFillColors       = colors
  lbres@vpWidthF           = 0.77 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.15 * vph     ; labelbar height
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.016         ; font height. default is small
  lbres@lbOrientation      = "horizontal"
  lbres@lbPerimOn          = False
  if ( center .eq. 1) then
    lbres@lbLabelAlignment   = "InteriorEdges"
  else
    lbres@lbLabelAlignment   = "BoxCenters"
  end if

  lbid = gsn_create_labelbar(wks,nboxes,""+(arr),lbres)

  amres                  = True
  amres@amParallelPosF   =  0.0
  amres@amOrthogonalPosF =  0.66    ; Bottom
  annoid = gsn_add_annotation(plot,lbid,amres)
  return(annoid)
end
