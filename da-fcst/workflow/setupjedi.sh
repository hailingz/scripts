#!/bin/sh 

# set up JEDI DA
# H.Zhang 202111

source ./setup.sh

#---------------      set up experiment     ---------------
export ROoper=NBAM
export ROOPR=GnssroBnd$ROoper
export ROPP2D=0
export RADIO=0

#--------------- ensemble and bump --------------
export nmem=16
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
export minimizer=DRPLanczos

#---------------JEDI resources-------------------------
export JEDIsrc=/work/noaa//da/hailingz/jedi/src/fv3-bundle_202110
export JEDIbin=/work/noaa//da/hailingz/jedi/build/fv3-bundle_202110/bin
export JEDIopt=/work/noaa/da/jedipara/opt/modules
export JEDImod=/work/noaa/da/jedipara/opt/modules/modulefiles/core

#---------------files-------------------------
export DATA_DIR=${TOP_DIR}/Data
export BUMP_DIR=${TOP_DIR}/Data/bump     
export BUMP_name=bump${layout}_c${RES}_$localization
export FIX_path=${DATA_DIR}/files
export radiodir=${DATA_DIR}/obs/oper/PT6H
export rodir=${DATA_DIR}/ioda2

#--------------- post process ----------------------
export CONVERT_RES=192
export CONVERT_RESP=$((CONVERT_RES+1))
