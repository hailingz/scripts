#!/bin/sh
# H.Zhang 202111

# experimental setup # shared by jedi and fv3
export TOP_DIR=/work/noaa/da/hailingz/work/new
export SCRIPT_DIR=`pwd`
export EXPT=ctrl
export SCRATCH=${TOP_DIR}/fv3scratch/${EXPT}
export INIT_DATE=2021010318
# edit your template directory if needed
export TEMPLATE_DIR=${TOP_DIR}/scripts/da-fcst/template
export assim_freq=6
export cycling=.true.
export CASE=C384
export RES=$(echo $CASE |cut -c2-5)
export RESP=$((RES+1))
export layout=8
export NTASKS_JEDI=$((layout*layout*6))
export DAmethod=3dhyb
export SEND="YES"
# ndate could be gone if using date math from Ben
export NDATE=/apps/contrib/NCEPLIBS/orion/utils/prod_util.v1.2.0/exec/ndate
export NLN="ln -sf"
export NCP="cp "
