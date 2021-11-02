echo "generating hofx yaml file"

set yaml     = $1
if ( -e $yaml ) rm -f $yaml

cat > $yaml <<EOF
window begin: ${yyyy_b}-${mm_b}-${dd_b}T${hh_b}:00:00Z
window length: PT6H
geometry:
  fms initialization:
    namelist filename: ${DATA_DIR}/files/fv3files/fmsmpp.nml
    field table filename: ${DATA_DIR}/files/fv3files/field_table_gfdl
  akbk: ${DATA_DIR}/files/fv3files/akbk64.nc4
  layout: [$layout,$layout]
  io_layout: [1,1]
  npx: $RESS
  npy: $RESS
  npz: 64
  fieldsets:
    - fieldset: ${FIX_path}//fieldsets/dynamics.yaml
    - fieldset: ${FIX_path}//fieldsets/ufo.yaml
state:
  filetype: gfs
  datapath: ${BKG_path}
  filename_core: ${yyyy}${mm}${dd}.${hh}0000.fv_core.res.nc
  filename_trcr: ${yyyy}${mm}${dd}.${hh}0000.fv_tracer.res.nc
  filename_sfcd: ${yyyy}${mm}${dd}.${hh}0000.sfc_data.nc
  filename_sfcw: ${yyyy}${mm}${dd}.${hh}0000.fv_srf_wnd.res.nc
  filename_cplr: ${yyyy}${mm}${dd}.${hh}0000.coupler.res
  state variables: [u,v,ua,va,T,DELP,sphum,ice_wat,liq_wat,o3mr,phis,
                    slmsk,sheleg,tsea,vtype,stype,vfrac,stc,smc,snwdph,
                    u_srf,v_srf,f10m]
observations:
- obs space:
    name: $ROOPR
    obsdatain:
      obsfile: ${rodir}/gnssro_obs_${DATE}.nc4
      obsgrouping:
        group variables: [ "record_number" ]
        sort variable: "impact_height"
        sort order: "ascending"
    obsdataout:
      obsfile: ${hofxout}/gnssro_output_${DATE}.nc4
    simulated variables: [bending_angle]
  obs operator:
    name: $ROOPR
    obs options:
EOF

set  OPTS=($OPTS)
if (${#OPTS} != 0) then
foreach iopt  ($OPTS)
    set  vector0=`echo  $iopt |cut -d : -f1`
    set  vector1=`echo  $iopt |cut -d : -f2`
    echo "      ${vector0}: ${vector1}" >> $yaml
echo $iopt $vector0 $vector1
end
endif

cat > part2.yaml << EOF
  obs filters:
  - filter: Domain Check
    filter variables:
    - name: bending_angle
    where:
    - variable:
        name: impact_height@MetaData
      minvalue: 0
      maxvalue: 50000
  - filter: ROobserror
    filter variables:
    - name: bending_angle
    errmodel: $errmodel
  - filter: $BackgroundCheck
    filter variables:
    - name: bending_angle 
    threshold: $threshold
EOF
cat part2.yaml >> $yaml


if ( $ROPP1D == 1 ) then

cat > ropp1d.yaml << EOF
- obs space:
    name: GnssroBndROPP1D
    obsdatain:
      obsfile: ${rodir}/gnssro_obs_${DATE}.nc4
      obsgrouping:
        group variables: [ 'record_number' ]
        sort variable: 'impact_height'
        sort order: 'ascending'
    obsdataout:
      obsfile: ${hofxout}/gnssro_ropp1d_${DATE}.nc4
    simulated variables: [bending_angle]
  obs operator:
    name: GnssroBndROPP1D
    obs options:
  obs filters:
  - filter: Domain Check
    filter variables:
    - name: [bending_angle]
    where:
    - variable:
        name: impact_height@MetaData
      minvalue: 0
      maxvalue: 50000
  - filter: ROobserror
    filter variables:
    - name: bending_angle
    errmodel: $errmodel
  - filter: Background Check
    filter variables:
    - name: [bending_angle]
    threshold: $threshold
EOF
cat ropp1d.yaml >> $yaml
endif

if ( $ROPP2D == 1 ) then
cat > ropp2d.yaml << EOF
- obs space:
    name: GnssroBndROPP2D
    obsdatain:
      obsfile: ${rodir}/gnssro_obs_${DATE}.nc4
      obsgrouping:
        group variables: [ 'record_number' ]
        sort variable: 'impact_height'
        sort order: 'ascending'
    obsdataout:
      obsfile: ${hofxout}/gnssro_ropp2d_${DATE}.nc4
    simulated variables: [bending_angle]
  obs operator:
    name: GnssroBndROPP2D
    obs options:
      n_horiz: 31
      res: 40.0
      top_2d: 8.0
  obs filters:
  - filter: Domain Check
    filter variables:
    - name: [bending_angle]
    where:
    - variable:
        name: impact_height@MetaData
      minvalue: 0
      maxvalue: 50000
  - filter: ROobserror
    n_horiz: 31
    filter variables:
    - name: bending_angle
    errmodel: $errmodel
  - filter: Background Check
    filter variables:
    - name: [bending_angle]
    threshold: $threshold
EOF
cat ropp2d.yaml >> $yaml
endif
