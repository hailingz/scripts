echo "generating 3denvar yaml file"

yaml=${DAmethod}.yaml
if [ -e $yaml ]; then rm -f $yaml; fi

BGNDATE=$($NDATE -3 $CDATE)
yyyy_b=`echo $BGNDATE | cut -c 1-4`
mm_b=`echo $BGNDATE | cut -c 5-6`
dd_b=`echo $BGNDATE | cut -c 7-8`
hh_b=`echo $BGNDATE | cut -c 9-10`

cat > $yaml << EOF
cost function:
  cost type: 3D-Var
  window begin: '${yyyy_b}-${mm_b}-${dd_b}T${hh_b}:00:00Z'
  window length: PT6H
  analysis variables: &3dvars [ua,va,T,DELP,sphum,ice_wat,liq_wat,o3mr]
  geometry:
    fms initialization:
       namelist filename: ${JEDIsrc}/fv3-jedi//test/Data/fv3files/fmsmpp.nml
       field table filename: ${JEDIsrc}/fv3-jedi//test/Data/fv3files/field_table_gfdl
    akbk: ${JEDIsrc}/fv3-jedi//test/Data/fv3files/akbk64.nc4
    layout: [$layout,$layout]
    io_layout: [1,1]
    npx: $RESP
    npy: $RESP
    npz: 64
    ntiles: 6
    fieldsets:
    - fieldset: ${JEDIsrc}/fv3-jedi//test/Data/fieldsets/dynamics.yaml
    - fieldset: ${JEDIsrc}/fv3-jedi//test/Data/fieldsets/ufo.yaml
  background:
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
  background error:
    covariance model: ensemble
    members:
    - filetype: gfs
      state variables: *3dvars
      datapath: ${ENS_path}/mem001/RESTART/
      filename_core: ${yyyy}${mm}${dd}.${hh}0000.fv_core.res.nc
      filename_trcr: ${yyyy}${mm}${dd}.${hh}0000.fv_tracer.res.nc
      filename_sfcd: ${yyyy}${mm}${dd}.${hh}0000.sfc_data.nc
      filename_sfcw: ${yyyy}${mm}${dd}.${hh}0000.fv_srf_wnd.res.nc
      filename_cplr: ${yyyy}${mm}${dd}.${hh}0000.coupler.res
EOF

imem=2
while [ $imem -le $nmem ]; do
m3=`printf "%03i" ${imem}`
cat >> $yaml << EOF
    - filetype: gfs
      state variables: *3dvars
      datapath: ${ENS_path}/mem${m3}/RESTART/
      filename_core: ${yyyy}${mm}${dd}.${hh}0000.fv_core.res.nc
      filename_trcr: ${yyyy}${mm}${dd}.${hh}0000.fv_tracer.res.nc
      filename_sfcd: ${yyyy}${mm}${dd}.${hh}0000.sfc_data.nc
      filename_sfcw: ${yyyy}${mm}${dd}.${hh}0000.fv_srf_wnd.res.nc
      filename_cplr: ${yyyy}${mm}${dd}.${hh}0000.coupler.res
EOF
   imem=$((imem+1))
done

cat >> $yaml << EOF
    localization:
      localization variables: *3dvars
      localization method: BUMP
      bump:
        prefix: ${BUMP_name}/fv3jedi_bumpparameters_nicas_3D_gfs
        method: loc 
        strategy: common
        load_nicas_local: 1
        verbosity: main
        io_keys: [common]
        io_values: [fixed_${localization}]
  observations:
  - obs space:
      name: $ROOPR
      obsdatain:
        obsfile: ${rodir}/gnssro_obs_${CDATE}.nc4
        obsgrouping:
          group variables: [ "record_number" ]
          sort variable: "impact_height"
          sort order: "ascending"
      obsdataout:
        obsfile: ${hofxout}/gnssro_${ROoper}_${CDATE}.nc4
      simulated variables: [bending_angle]
    obs operator:
      name: $ROOPR
      obs options:
EOF

OPTS=("$@")
if [ ${#OPTS[@]} > 0 ]; then
  for iopt in ${OPTS[@]}
  do
    vector0=`echo  $iopt |cut -d : -f1`
    vector1=`echo  $iopt |cut -d : -f2`
    echo "        ${vector0}: ${vector1}" >> $yaml
  done
fi

cat >> $yaml <<  EOF
    obs error:
      covariance model: diagonal
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

cat >> $yaml <<   EOF
variational:
  minimizer:
    algorithm: $minimizer
  iterations:
  - ninner: $Ninter1
    gradient norm reduction: 1e-10
    test: on
    geometry:
      akbk: ${JEDIsrc}/fv3-jedi/test/Data/fv3files/akbk64.nc4
      layout: [$layout,$layout]
      io_layout: [1,1]
      npx: $RESP
      npy: $RESP
      npz: 64
      ntiles: 6
      fieldsets:
      - fieldset: ${JEDIsrc}/fv3-jedi//test/Data/fieldsets/dynamics.yaml
      - fieldset: ${JEDIsrc}/fv3-jedi//test/Data/fieldsets/ufo.yaml
    diagnostics:
      departures: ombg
  iterations:
  - ninner: $Ninter2
    gradient norm reduction: 1e-10
    test: on
    geometry:
      akbk: ${JEDIsrc}/fv3-jedi/test/Data/fv3files/akbk64.nc4
      layout: [$layout,$layout]
      io_layout: [1,1]
      npx: $RESP
      npy: $RESP
      npz: 64
      ntiles: 6
      fieldsets:
      - fieldset: ${JEDIsrc}/fv3-jedi//test/Data/fieldsets/dynamics.yaml
      - fieldset: ${JEDIsrc}/fv3-jedi//test/Data/fieldsets/ufo.yaml
    diagnostics:
      departures: ombg
final:
  diagnostics:
    departures: oman
output:
  filetype: gfs
  datapath: ${analysisout}
  filename_core: fv_core.res.nc
  filename_trcr: fv_tracer.res.nc
  filename_sfcd: sfc_data.nc
  filename_sfcw: fv_srf_wnd.res.nc
  filename_cplr: coupler.res
  first: PT0H
  frequency: PT1H

EOF
