#!/bin/sh
# H.Zhang 202111

USE_METASCHEDULAR=${USE_METASCHEDULAR:-F}

if [[ ${USE_METASCHEDULAR} == F ]]; then
  # experimental setup # shared by jedi and fv3
  export TOP_DIR=/work/noaa/da/hailingz/work/new
  export SCRIPT_DIR=`pwd`
  export EXPT=ctrl
  export SCRATCH=${TOP_DIR}/fv3scratch/${EXPT}
  export INIT_DATE=2021010318
  # edit your template directory if needed
  export TEMPLATE_DIR=${TOP_DIR}/scripts/da-fcst/template
  export assim_freq=6
  export RES=384
  export CASE=C${RES}
  export DAmethod=3dhyb
fi


export cycling=.true.
export RESP=$((RES+1))
export layout=8
export NTASKS_JEDI=$((layout*layout*6))
export SEND="YES"
# ndate could be gone if using date math from Ben
export NDATE=/apps/contrib/NCEPLIBS/orion/utils/prod_util.v1.2.0/exec/ndate
export NLN="ln -sf"
export NCP="cp "
