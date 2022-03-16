echo "generating hyb-3dvar yaml file"

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
  analysis variables: &3dvars  [ua,va,t,ps,sphum,liq_wat,o3mr]
  geometry:
    fms initialization:
       namelist filename: ${JEDIsrc}/fv3-jedi/test/Data/fv3files/fmsmpp.nml
       field table filename: ${JEDIsrc}/fv3-jedi/test/Data/fv3files/field_table_gfdl
    akbk: ${JEDIsrc}/fv3-jedi/test/Data/fv3files/akbk${NPZ}.nc4
    layout: [$layout,$layout]
    io_layout: [1,1]
    npx: $RESP
    npy: $RESP
    npz: $NPZ
    ntiles: 6
    fieldsets:
    - fieldset: ${JEDIsrc}/fv3-jedi/test/Data/fieldsets/dynamics.yaml
    - fieldset: ${JEDIsrc}/fv3-jedi/test/Data/fieldsets/ufo.yaml
  background:
    filetype: gfs
    datapath: ${BKG_path}
    filename_core: ${yyyy}${mm}${dd}.${hh}0000.fv_core.res.nc
    filename_trcr: ${yyyy}${mm}${dd}.${hh}0000.fv_tracer.res.nc
    filename_sfcd: ${yyyy}${mm}${dd}.${hh}0000.sfc_data.nc
    filename_sfcw: ${yyyy}${mm}${dd}.${hh}0000.fv_srf_wnd.res.nc
    filename_cplr: ${yyyy}${mm}${dd}.${hh}0000.coupler.res
    state variables: [u,v,t,delp,sphum,ice_wat,liq_wat,o3mr,phis,
                      slmsk,sheleg,tsea,vtype,stype,vfrac,stc,smc,snwdph,
                      rainwat,snowwat,graupel,cld_amt,w,DZ,
                      u_srf,v_srf,f10m]
  background error:
    covariance model: hybrid
    components:
    - covariance:
        covariance model: SABER
        saber blocks:
        - saber block name: BUMP_NICAS
          saber central block: true
          input variables: &control_vars [psi,chi,t,ps,sphum,liq_wat,o3mr]
          output variables: *control_vars
          active variables: &active_vars [psi,chi,t,ps,sphum,liq_wat,o3mr]
          bump:
            datadir: $staticB_TOP
            verbosity: main
            strategy: specific_univariate
            load_nicas_local: true
            grids:
            - prefix: nicas_${trainperiod}/nicas_${trainperiod}_3D
              variables: [stream_function,velocity_potential,air_temperature,specific_humidity,cloud_liquid_water,ozone_mass_mixing_ratio]
            - prefix: nicas_${trainperiod}/nicas_${trainperiod}_2D
              variables: [surface_pressure]
            universe radius:
              filetype: gfs
              psinfile: true
              datapath: ${staticB_TOP}/cor_${trainperiod}
              filename_core: cor_rh.fv_core.res.nc
              filename_trcr: cor_rh.fv_tracer.res.nc
              filename_cplr: cor_rh.coupler.res
              date: $sampledate
        - saber block name: StdDev
          input variables: *control_vars
          output variables: *control_vars
          active variables: *active_vars
          file:
            filetype: gfs
            psinfile: true
            datapath: ${staticB_TOP}/var_${trainperiod}
            filename_core: stddev.fv_core.res.nc
            filename_trcr: stddev.fv_tracer.res.nc
            filename_cplr: stddev.coupler.res
            date: $sampledate
        - saber block name: BUMP_VerticalBalance
          input variables: *control_vars
          output variables: *control_vars
          active variables: *active_vars
          bump:
            datadir: ${staticB_TOP}
            prefix: vbal_${trainperiod}/vbal_${trainperiod}
            verbosity: main
            universe_rad: 2000.0e3
            load_vbal: true
            load_samp_local: true
            fname_samp: vbal_${fnamesample}/vbal_${fnamesample}_sampling
            vbal_block: [true, true,false, true,false,false]
        - saber block name: BUMP_PsiChiToUV
          input variables: *control_vars
          output variables: *3dvars
          active variables: [psi,chi,ua,va]
          bump:
            datadir: ${staticB_TOP}
            prefix: psichitouv_${trainperiod}/psichitouv_${trainperiod}
            verbosity: main
            universe_rad: 2000.0e3
            load_wind_local: true
      weight:
        value: $weight_static
    - covariance:
        covariance model: ensemble
        members from template:
          template:
            filetype: gfs
            state variables:  &ensvars [ud,vd,t,ps,sphum,liq_wat,o3mr]
            datapath: ${ENS_path}/mem%mem%/RESTART/
            filename_core: ${yyyy}${mm}${dd}.${hh}0000.cold2fv3.fv_core.res.nc
            filename_trcr: ${yyyy}${mm}${dd}.${hh}0000.cold2fv3.fv_tracer.res.nc
            filename_cplr: ${yyyy}${mm}${dd}.${hh}0000.cold2fv3.coupler.res
          pattern: %mem%
          nmembers: $nmem
          zero padding: 3
        localization:
          localization method: SABER
          saber block:
            saber block name: BUMP_NICAS
            input variables: *3dvars
            output variables: *3dvars
            linear variable change:
              linear variable change name: Control2Analysis
              input variables: *ensvars
              output variables: *3dvars
            bump:
              prefix: ${BUMP_name}/fv3jedi_bumpparameters_nicas_3D_gfs
              method: loc
              strategy: common
              load_nicas_local: true
              verbosity: main
              io_keys: [common]
              io_values: [fixed_${localization}]
      weight:
        value: $weight_ensemble
  observations:
  - obs space:
      name: $ROOPR
      obsdatain:
        obsfile: ${OBS_DIR}/gnssro_obs_${CDATE}.nc4
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
      akbk: ${JEDIsrc}/fv3-jedi/test/Data/fv3files/akbk${NPZ}.nc4
      layout: [$layout,$layout]
      io_layout: [1,1]
      npx: $RESP
      npy: $RESP
      npz: $NPZ
      ntiles: 6
      fieldsets:
      - fieldset: ${JEDIsrc}/fv3-jedi/test/Data/fieldsets/dynamics.yaml
      - fieldset: ${JEDIsrc}/fv3-jedi/test/Data/fieldsets/ufo.yaml
    diagnostics:
      departures: ombg
  - ninner: $Ninter2
    gradient norm reduction: 1e-10
    test: on
    geometry:
      akbk: ${JEDIsrc}/fv3-jedi/test/Data/fv3files/akbk${NPZ}.nc4
      layout: [$layout,$layout]
      io_layout: [1,1]
      npx: $RESP
      npy: $RESP
      npz: $NPZ
      ntiles: 6
      fieldsets:
      - fieldset: ${JEDIsrc}/fv3-jedi/test/Data/fieldsets/dynamics.yaml
      - fieldset: ${JEDIsrc}/fv3-jedi/test/Data/fieldsets/ufo.yaml
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
