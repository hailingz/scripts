#!/usr/bin/bash
#-------------------------------------------------------------------------------
#SBATCH --job-name=convert
#SBATCH -A da-cpu
#SBATCH -p orion
#SBATCH -q batch
#SBATCH --ntasks 6
#SBATCH --cpus-per-task=1
#SBATCH -t 10:00
#SBATCH --output=post_convert.%j
#-------------------------------------------------------------------------------

###### edit HERE #######
DATE=2021010100
RES_orig=385
RES_target=193
FIX_dir=/work/noaa/da/hailingz/jedi/src/fv3-bundle_202110/fv3-jedi/test/Data
JEDIbin=/work/noaa/da/hailingz/jedi/build/fv3-bundle_20211022/bin
###### edit HERE #######

yyyy=`echo $DATE | cut -c 1-4`
mm=`echo $DATE | cut -c 5-6`
dd=`echo $DATE | cut -c 7-8`
hh=`echo $DATE | cut -c 9-10`
PREDATE=`~/lib/da_advance_time.exe $DATE -6`
ymd_pre=`echo $PREDATE | cut -c 1-8`
hh_pre=`echo $PREDATE | cut -c 9-10`

###### edit HERE #######
prefix="enkfgdas."
BKG=/work/noaa/da/hailingz/work/usaf/Data/ens_c384/
BKG_dir=${BKG}/${prefix}${ymd_pre}/${hh_pre}/mem001/RESTART/
OUT=output_c${RES_target}
###### edit HERE #######

source /etc/bashrc
module purge
JEDI_OPT=/work/noaa/da/jedipara/opt/modules
module use /work/noaa/da/jedipara/opt/modules/modulefiles/core
module load jedi/intel-impi
module list 
ulimit -s unlimited
ulimit -v unlimited
set SLURM_EXPORT_ENV ALL
set HDF5_USE_FILE_LOCKING FALSE
set OOPS_DEBUG 1
set OOPS_TRACE 1


if [ ! -d ${OUT} ]; then
 mkdir -p ${OUT}
fi

if [ ! -d log ]; then
     mkdir log
fi
  cat > convert_fv3_resolution.yaml << EOF
input geometry:
  fms initialization:
    namelist filename: ${FIX_dir}/fv3files/fmsmpp.nml
    field table filename: ${FIX_dir}/fv3files/field_table_gfdl
  akbk: ${FIX_dir}/fv3files/akbk64.nc4
  layout: [1,1] 
  io_layout: [1,1]
  npx: $RES_orig
  npy: $RES_orig
  npz: 64
  ntiles: 6
  fieldsets:
    - fieldset: ${FIX_dir}/fieldsets/dynamics.yaml
output geometry:
  akbk: ${FIX_dir}/fv3files/akbk64.nc4
  layout: [1,1]
  io_layout: [1,1]
  npx: $RES_target
  npy: $RES_target
  npz: 64
  ntiles: 6
  fieldsets:
    - fieldset: ${FIX_dir}/fieldsets/dynamics.yaml
states:
- input:
    filetype: gfs
    state variables: [u,v,ua,va,T,DELP,sphum,ice_wat,liq_wat,o3mr,phis,
                      slmsk,sheleg,tsea,vtype,stype,vfrac,stc,smc,snwdph,
                      u_srf,v_srf,f10m]
    datapath: $BKG_dir
    filename_core: ${yyyy}${mm}${dd}.${hh}0000.fv_core.res.nc
    filename_trcr: ${yyyy}${mm}${dd}.${hh}0000.fv_tracer.res.nc
    filename_sfcd: ${yyyy}${mm}${dd}.${hh}0000.sfc_data.nc
    filename_sfcw: ${yyyy}${mm}${dd}.${hh}0000.fv_srf_wnd.res.nc
    filename_cplr: ${yyyy}${mm}${dd}.${hh}0000.coupler.res
  output:
    filetype: gfs
    datapath: ${OUT}
    filename_core: ${yyyy}${mm}${dd}.${hh}0000.fv_core.res.nc
    filename_trcr: ${yyyy}${mm}${dd}.${hh}0000.fv_tracer.res.nc
    filename_sfcd: ${yyyy}${mm}${dd}.${hh}0000.sfc_data.nc
    filename_sfcw: ${yyyy}${mm}${dd}.${hh}0000.fv_srf_wnd.res.nc
    filename_cplr: ${yyyy}${mm}${dd}.${hh}0000.coupler.res
EOF

srun --ntasks=6 --cpu_bind=core --distribution=block:block ${JEDIbin}/fv3jedi_convertstate.x convert_fv3_resolution.yaml log/conv.log 
