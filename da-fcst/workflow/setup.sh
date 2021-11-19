#!/bin/sh
# H.Zhang 202111

# experimental setup # shared by jedi and fv3
export TOP_DIR=/work/noaa/da/hailingz/work/c2nwp
export SCRIPT_DIR=`pwd`
export EXPT=ctrl
export INIT_DATE=2021010400
export TEMPLATE_DIR=${TOP_DIR}/template
export assim_freq=6
export cycling=.true.
export CASE=C384
export RES=$(echo $CASE |cut -c2-5)
export RESP=$((RES+1))
export layout=6
export NTASKS_JEDI=$((layout*layout*6))
export DAmethod=3dhyb
export SEND="YES"
export TOOL="${HOME}/lib/"
export NDATE=/apps/contrib/NCEPLIBS/orion/utils/prod_util.v1.2.0/exec/ndate
export NLN="ln -sf"
export NCP="cp "
