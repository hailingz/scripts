#!/bin/sh 

# set up JEDI DA
# H.Zhang 202111

USE_METASCHEDULAR=${USE_METASCHEDULAR:-F}

if [[ ${USE_METASCHEDULAR} == F ]]; then
  source ./setup.sh
fi

#---------------      set up experiment     ---------------
export ROoper=NBAM
export ROOPR=GnssroBnd$ROoper
export ROPP2D=0
export RADIO=0

#--------------- ensemble and bump --------------
export nmem=20
export localization=2200km_0.58

#---------------  edit operator options here ---------
export errmodel="NRL"
export threshold=4
export srmethod=NBAM
export OPTS=("vertlayer:full"  "use_compress:1"  "super_ref_qc:NBAM"  "sr_steps:2")
export BackgroundCheck="Background Check RONBAM"

#--------------- DA config  -------------------------
export Ninter1=50 
export Ninter2=25
export minimizer=DRIPCG
export weight_static=0.1
export weight_ensemble=0.9

#--------------- JEDI run time log print --------------
export OOPS_TRACE=0
export OOPS_DEBUG=0

#---------------JEDI resources-------------------------
export JEDIsrc=/work/noaa/da/hailingz/jedi/src/fv3-bundle_202201
export JEDIbin=/work/noaa/da/hailingz/jedi/build/fv3-bundle_202201/bin
export JEDIopt=/work/noaa/da/jedipara/opt/modules
export JEDImod=/work/noaa/da/jedipara/opt/modules/modulefiles/core

#---------------files-------------------------
if [[ ${USE_METASCHEDULAR} == F ]]; then
# please  do NOT change this DATA_DIR as it is a fixed data feed now
  export BUMP_DIR=${PREP_DATA_DIR}/bump
fi
export BUMP_name=bump${layout}_c${RES}_$localization
export OBS_DIR=${PREP_DATA_DIR}/ioda
#-------------static B files---------------------------
export staticB_TOP=${PREP_DATA_DIR}/StaticBTraining/c${RES}/bump_1.0
export trainperiod=2020010100-2020013100
export fnamesample=${trainperiod:11:10}
export sampledate="${fnamesample:0:4}-${fnamesample:4:2}-${fnamesample:6:2}T${fnamesample:8:2}:00:00Z"
#--------------- post process ----------------------
export CONVERT_RES=192
export CONVERT_RESP=$((CONVERT_RES+1))
