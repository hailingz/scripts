echo "generating hyb-3dvar yaml file"

yaml=${DAmethod}.yaml
if [ -e $yaml ]; then rm -f $yaml; fi

BGNDATE=$( date -u --date="-3 hours ${CDATE:0:4}-${CDATE:4:2}-${CDATE:6:2} ${CDATE:8:2}" +%Y%m%d%H )
yyyy_b=`echo $BGNDATE | cut -c 1-4`
mm_b=`echo $BGNDATE | cut -c 5-6`
dd_b=`echo $BGNDATE | cut -c 7-8`
hh_b=`echo $BGNDATE | cut -c 9-10`

yyyy=${yyyy:-${CDATE:0:4}}
mm=${mm:-${CDATE:4:2}}
dd=${dd:-${CDATE:6:2}}
hh=${hh:-${CDATE:8:2}}

dtg=${dtg:-${yyyy}${mm}${dd}.${hh}0000}
dtg_e=${dtg_e:-${yyyy}${mm}${dd}.${hh}0000}

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
    filetype: fms restart
    datetime: '${yyyy}-${mm}-${dd}T${hh}:00:00Z'
    datapath: ${BKG_path}
    filename_core: ${dtg}.fv_core.res.nc
    filename_trcr: ${dtg}.fv_tracer.res.nc
    filename_sfcd: ${dtg}.sfc_data.nc
    filename_sfcw: ${dtg}.fv_srf_wnd.res.nc
    filename_cplr: ${dtg}.coupler.res
    state variables: [u,v,t,delp,sphum,ice_wat,liq_wat,o3mr,phis,
                      slmsk,sheleg,tsea,vtype,stype,vfrac,stc,smc,snwdph,
                      rainwat,snowwat,graupel,cld_amt,w,DZ,
                      u_srf,v_srf,f10m]
  background error:
    datetime: '2020-01-31T00:00:00Z'
    set datetime on read: true
    covariance model: hybrid
    components:
    - covariance:
        covariance model: SABER
        saber blocks:
        - saber block name: BUMP_NICAS
          datetime: '2020-01-31T00:00:00Z'
          set datetime on read: true
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
              datetime: '2020-01-31T00:00:00Z'
              set datetime on read: true
              filetype: fms restart
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
            filetype: fms restart
            datetime: '2020-01-31T00:00:00Z'
            set datetime on read: true
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
            filetype: fms restart
            datetime: '${yyyy}-${mm}-${dd}T${hh}:00:00Z'
            set datetime on read: true
            state variables:  &ensvars [ud,vd,t,ps,sphum,liq_wat,o3mr]
            datapath: ${ENS_path}/mem%mem%/RESTART/
            filename_core: ${dtg_e}.cold2fv3.fv_core.res.nc
            filename_trcr: ${dtg_e}.cold2fv3.fv_tracer.res.nc
            filename_cplr: ${dtg_e}.cold2fv3.coupler.res
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
        obsfile: ${OBS_DIR}/gnssro/gnssro_obs_${CDATE}.nc4
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
      - variable:
          name: occulting_sat_id@MetaData
        is_in: 750-755
    - filter: $BackgroundCheck
      filter variables:
      - name: bending_angle 
      threshold: $threshold
    - filter: ROobserror
      filter variables:
      - name: bending_angle
      errmodel: $errmodel
    - filter: Background Check RONBAM
      filter variables:
      - name: bending_angle
      action:
        name: RONBAMErrInflate
  - obs space:
      name: radiosonde
      obsdatain:
        obsfile: ${OBS_DIR}/${yyyy_b}${mm_b}${dd_b}T${hh_b}Z_PT6H_radiosonde.nc4
        obsgrouping:
          group variables: [station_id, LaunchTime]
          sort variable: air_pressure
          sort order: ascending
      obsdataout:
        obsfile: ${hofxout}/radiosonde_${CDATE}.nc4
      simulated variables: [air_temperature, specific_humidity, eastward_wind, northward_wind]
    obs operator:
      name: Composite
      components:
      - name: VertInterp
        variables:
        - name: air_temperature
        - name: specific_humidity
        - name: eastward_wind
        - name: northward_wind
      da_psfc_scheme: UKMO
    obs filters:
      - filter: Bounds Check
        filter variables:
        - name: air_temperature
        minvalue: 195
        maxvalue: 327
        action:
          name: reject
      - filter: Bounds Check
        filter variables:
        - name: specific_humidity
        minvalue: 1.0E-8
        maxvalue: 0.034999999
        action:
          name: reject
      - filter: Bounds Check
        filter variables:
        - name: eastward_wind
        - name: northward_wind
        minvalue: -130
        maxvalue: 130
        action:
          name: reject
      - filter: Bounds Check
        filter variables:
        - name: eastward_wind
        - name: northward_wind
        test variables:
        - name: Velocity@ObsFunction
        maxvalue: 130.0
        action:
          name: reject
      - filter: Perform Action
        filter variables:
        - name: eastward_wind
        - name: northward_wind
        action:
          name: assign error
          error parameter: 1.4
      - filter: Perform Action
        filter variables:
        - name: specific_humidity
        action:
          name: assign error
          error parameter: 1.0E-3
      - filter: Perform Action
        filter variables:
        - name: air_temperature
        action:
          name: assign error
          error function:
            name: ObsErrorModelStepwiseLinear@ObsFunction
            options:
              xvar:
                name: MetaData/air_pressure
              xvals: [100000, 95000, 90000, 85000, 35000, 30000, 25000, 20000, 15000, 10000, 7500, 5000, 4000, 3000, 2000, 1000]
              errors: [1.2, 1.1, 0.9, 0.8, 0.8, 0.9, 1.2, 1.2, 1.0, 0.8, 0.8, 0.9, 0.95, 1.0, 1.25, 1.5]
      - filter: Perform Action
        filter variables:
        - name: specific_humidity
        action:
          name: assign error
          error function:
            name: ObsErrorModelStepwiseLinear@ObsFunction
            options:
              xvar:
                name: MetaData/air_pressure
              xvals: [25000, 20000, 10]
              errors: [0.2, 0.4, 0.8]
              scale_factor_var: ObsValue/specific_humidity
      - filter: Perform Action
        filter variables:
        - name: eastward_wind
        - name: northward_wind
        action:
          name: assign error
          error function:
            name: ObsErrorModelStepwiseLinear@ObsFunction
            options:
              xvar:
                name: MetaData/air_pressure
              xvals: [100000, 95000, 80000, 65000, 60000, 55000, 50000, 45000, 40000, 35000, 30000, 25000, 20000, 15000, 10000]
              errors: [1.4, 1.5, 1.6, 1.8, 1.9, 2.0, 2.1, 2.3, 2.6, 2.8, 3.0, 3.2, 2.7, 2.4, 2.1]
      - filter: Bounds Check
        filter variables:
        - name: eastward_wind
        - name: northward_wind
        test variables:
        - name: WindDirAngleDiff@ObsFunction
          options:
            minimum_uv: 3.5
        maxvalue: 50.0
        action:
          name: reject
        defer to post: true
      - filter: Background Check
        filter variables:
        - name: air_temperature
        threshold: 7.0
        absolute threshold: 9.0
        action:
          name: reject
        defer to post: true
      - filter: Background Check
        filter variables:
        - name: eastward_wind
        - name: northward_wind
        threshold: 6.0
        absolute threshold: 19.0
        action:
          name: reject
        defer to post: true
      - filter: Background Check
        filter variables:
        - name: specific_humidity
        threshold: 8.0
        action:
          name: reject
        defer to post: true
      - filter: RejectList
        filter variables:
        - name: northward_wind
        where:
        - variable: QCflagsData/eastward_wind
          minvalue: 1
        defer to post: true
      - filter: RejectList
        filter variables:
        - name: eastward_wind
        where:
        - variable: QCflagsData/northward_wind
          minvalue: 1
        defer to post: true
      - filter: RejectList
        filter variables:
        - name: specific_humidity
        where:
        - variable: QCflagsData/air_temperature
          minvalue: 1
        defer to post: true
EOF

cat >> $yaml <<   EOF
variational:
  minimizer:
    algorithm: $minimizer
  iterations:
  - ninner: $Ninter1
    gradient norm reduction: 1e-5
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
  filetype: fms restart
  date: '${yyyy}-${mm}-${dd}T${hh}:00:00Z'
  datapath: ${analysisout}
  filename_core: fv_core.res.nc
  filename_trcr: fv_tracer.res.nc
  filename_sfcd: sfc_data.nc
  filename_sfcw: fv_srf_wnd.res.nc
  filename_cplr: coupler.res
  first: PT0H
  frequency: PT1H

EOF
