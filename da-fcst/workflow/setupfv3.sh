#!/bin/sh

# set up fv3 forecast
# H.Zhang 202111

source ./setup.sh

# assimilation setup
export CDUMP=gdas
export rCDUMP=$CDUMP
export assim_freq=6
export DOIAU=.false.
export warm_start=.true.
export rst_invt1=3
export NTHREADS_FV3=1
export RUN_CCPP=NO
export IAU_FHROT=3
export IAU_OFFSET=6
export MONO=non-mono
export DELTIM=240
export print_esmf=.false.
export restart_interval='3 -1'
export make_nh=.false.
export FTSFS=10
export FHOUT_HF=${FHOUT_HF:-1}
export FHMAX_HF=${FHMAX_HF:-0}
export FHOUT=${FHOUT:-3}
export NSOUT=${NSOUT:-"-1"}
export FHMAX=6
export FHOUT=6
export FHMIN=3
export FHCYC=1
# assimilation setup

# resolution 
export CASE=C384
# resolution 

# fv3 layout and computing resource 
export ntiles=6
export layout_x=6
export layout_y=6
export NNODE=16
export TASKS_PER_NODE=16
export WRTTASK_PER_GROUP=40
export NTASKS=$(($layout_x*$layout_y*6+WRTTASK_PER_GROUP))
# fv3 layout and computing resource 

# spectral truncation and regular grid resolution based on FV3 resolution 
res=$(echo $CASE |cut -c2-5)
resp=$((res+1))
export npx=$resp
export npy=$resp
export JCAP_CASE=$((2*res-2))
export LONB_CASE=$((4*res))
export LATB_CASE=$((2*res))
export JCAP=${JCAP:-$JCAP_CASE}
export LONB=${LONB:-$LONB_CASE}
export LATB=${LATB:-$LATB_CASE}
export LONB_IMO=${LONB_IMO:-$LONB_CASE}
export LATB_JMO=${LATB_JMO:-$LATB_CASE}
export npz=64
export LEVS=65
# spectral truncation and regular grid resolution based on FV3 resolution 

# executables and fix files
export TOOL="~/lib/"
export NDATE=/apps/contrib/NCEPLIBS/orion/utils/prod_util.v1.2.0/exec/ndate
export NLN="ln -sf"
export NCP="cp "
export HOMEgfs=/work/noaa/da/cmartin/noscrub/UFO_eval/global-workflow
export FCSTEXECDIR=$HOMEgfs/sorc/fv3gfs.fd/NEMS/exe
export FCSTEXEC=global_fv3gfs.x
export FIX_DIR=/work/noaa/da/hailingz/fix/fv3/cory
export FIX_AM=${FIX_DIR}/fix_am
export FIXfv3=${FIX_DIR}/fix_fv3_gmted2010
export PARMgfs=${HOMEgfs}/parm
export PARM_POST=${PARMgfs}/post
export PARM_FV3DIAG=${PARMgfs}/parm_fv3diag
export FIXgfs=${HOMEgfs}/fix
export USHgfs=${HOMEgfs}/ush
export UTILgfs=${HOMEgfs}/util
export EXECgfs=${HOMEgfs}/exec
export SCRgfs=${HOMEgfs}/scripts
export FNGLAC="$FIX_AM/global_glacier.2x2.grb"
export FNGLAC="$FIX_AM/global_glacier.2x2.grb"
export FNMXIC="$FIX_AM/global_maxice.2x2.grb"
export FNTSFC="$FIX_AM/RTGSST.1982.2012.monthly.clim.grb"
export FNSNOC="$FIX_AM/global_snoclim.1.875.grb"
export FNZORC="igbp"
export FNALBC2="$FIX_AM/global_albedo4.1x1.grb"
export FNAISC="$FIX_AM/CFSR.SEAICE.1982.2012.monthly.clim.grb"
export FNTG3C="$FIX_AM/global_tg3clim.2.6x1.5.grb"
export FNVEGC="$FIX_AM/global_vegfrac.0.144.decpercent.grb"
export FNMSKH="$FIX_AM/global_slmask.t1534.3072.1536.grb"
export FNVMNC="$FIX_AM/global_shdmin.0.144x0.144.grb"
export FNVMXC="$FIX_AM/global_shdmax.0.144x0.144.grb"
export FNSLPC="$FIX_AM/global_slope.1x1.grb"
export FNALBC="$FIX_AM/global_snowfree_albedo.bosu.t${JCAP}.${LONB}.${LATB}.rg.grb"
export FNVETC="$FIX_AM/global_vegtype.igbp.t${JCAP}.${LONB}.${LATB}.rg.grb"
export FNSOTC="$FIX_AM/global_soiltype.statsgo.t${JCAP}.${LONB}.${LATB}.rg.grb"
export FNABSC="$FIX_AM/global_mxsnoalb.uariz.t${JCAP}.${LONB}.${LATB}.rg.grb"
export FNSMCC="$FIX_AM/global_soilmgldas.statsgo.t${JCAP}.${LONB}.${LATB}.grb"
[[ ! -f $FNALBC ]] && FNALBC="$FIX_AM/global_snowfree_albedo.bosu.t1534.3072.1536.rg.grb"
[[ ! -f $FNVETC ]] && FNVETC="$FIX_AM/global_vegtype.igbp.t1534.3072.1536.rg.grb"
[[ ! -f $FNSOTC ]] && FNSOTC="$FIX_AM/global_soiltype.statsgo.t1534.3072.1536.rg.grb"
[[ ! -f $FNABSC ]] && FNABSC="$FIX_AM/global_mxsnoalb.uariz.t1534.3072.1536.rg.grb"
# executables and fix files

#fv3 tables
export DIAG_TABLE=$PARM_FV3DIAG/diag_table
export DATA_TABLE=$PARM_FV3DIAG/data_table
export FIELD_TABLE=$PARM_FV3DIAG/field_table_gfdl_satmedmf
#fv3 tables

# model configure
  # output and format
export OUTPUT_GRID="gaussian_grid"
export OUTPUT_FILETYPES="netcdf"
export WRITE_NEMSIOFLIP=".true."
export WRITE_FSYNCFLAG=".true."
export WRITE_DOPOST=.false.
export affix="nc" 
export QUILTING=.true.
export print_freq=6
 #
export TYPE="nh"   
export cplwav=".false."
export do_sat_adj=".true."
 #
# model configure

# parameters and namelists
export IAER=5111
export ICO2=2
export NST_MODEL=2
export NST_SPINUP=0
export NST_RESV=0
export ZSEA1=0
export ZSEA2=0
export nstf_name=${nstf_name:-"$NST_MODEL,$NST_SPINUP,$NST_RESV,$ZSEA1,$ZSEA2"}
export nst_anl=".false."
export blocksize=32
export na_init=1
export filtered_terrain=".true."
export gfs_dwinds=".true."
export no_dycore=".false."
export dycore_only=".false."
export chksum_debug=".false."
export consv_te=1.0  
export k_split=2
export n_split=6
export ncld=5
export imp_physics=11
export cal_pre=.false.
export random_clds=.false.
export cdmbgwd=1.1,0.72,1.0,1.0
export lsm=1
export nst_anl=.true.
export lgfdlmprad=.true.
export effr_in=.true.
export ldiag_ugwp=.false.
export do_ugwp=.false.
export do_tofd=.true.
export do_sppt=.true.
export do_shum=.true.
export do_skeb=.true.
export tau=5.0
export rf_cutoff=1.0e3
export d2_bg_k1=0.20
export d2_bg_k2=0.0
export nwat=6
export dnats=1
export nord=2
export dddmp=0.1
export d4_bg=0.12
export vtdm4=0.02
export n_sponge=42
export phys_hydrostatic=.false.
export hydrostatic=.false.
export use_hydro_pressure=.false.
# parameters and namelists

export CDATE=2021010400
export PDY=$(echo $CDATE | cut -c1-8)
export cyc=$(echo $CDATE | cut -c9-10)
export PDY=$PDY
export cyc=$cyc
