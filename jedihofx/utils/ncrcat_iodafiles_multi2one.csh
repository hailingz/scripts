#!/usr/bin/csh
###### script to concatenate multiple IODA output files to one ####
###### 20211026 Hailing Zhang and Fabio  Diniz #############
module load nco
set     TOP_DIR=/work2/noaa/da/hailingz/work/newinstru
source  ${TOP_DIR}/script/setup.csh
set    DATE=2021011000
set    DATA_DIR=${TOP_DIR}/run/${EXPT}/${DATE}/output/hofx/
set observable    = "bending_angle"
set varlist_meta  = "occulting_sat_id,occulting_sat_is,reference_sat_id,record_number,impact_parameter,impact_height,latitude,longitude,time,ascending_flag,gnss_sat_class"

@ nfile = ( $layout * $layout  * 6 - 1 )
set nfile=3

set in = 0
while ( $in <= $nfile )
    set n4=`printf "%04i" ${in}`
    ncks -h -g hofx,ObsValue,EffectiveQC,SRflag,MetaData  -v ${observable},$varlist_meta  --mk_rec_dmn nlocs ${DATA_DIR}/gnssro_output_${DATE}_${n4}.nc4 f0_${in}.nc4

  if ( $in == 0 ) then
     mv  f0_${in}.nc4 gnssro_output_${DATE}.nc4
  else 
     ncrcat -h gnssro_output_${DATE}.nc4 f0_${in}.nc4  temp.nc4
     mv  temp.nc4  gnssro_output_${DATE}.nc4 
  endif
  rm f?_${in}.nc4
  @ in = ( $in + 1 )
end

