#!/bin/sh
# H.Zhang 202203

USE_METASCHEDULAR=${USE_METASCHEDULAR:-F}

if [[ ${USE_METASCHEDULAR} == F ]]; then
  # experimental setup # shared by jedi and fv3
  export TOP_DIR=/work/noaa/da/hailingz/work/cycle127
  export SCRIPT_DIR=`pwd`
  export EXPT=hyb20mem
  export SCRATCH=${TOP_DIR}/fv3scratch/${EXPT}
  export INIT_DATE=2021080112
  # edit your template directory if needed
  export TEMPLATE_DIR=${TOP_DIR}/scripts/da-fcst/template
  export INPUT_DATA_DIR=/work/noaa/da/bruston/jedi/fv3
  export PREP_DATA_DIR=/work2/noaa/da/hailingz/work/Data/
  export OBS_DIR=/work2/noaa/da/hailingz/work/Data/ioda
  export assim_freq=6
  export RES=384                  
  export CASE=C${RES}
  export NPZ=127                    # model vertical layer
  export DAmethod=hyb3dvar_ens-gaussian2restart
fi

export cycling=.true.
export RESP=$((RES+1))
export layout=7  #The layout number was the layout number BUMP used to generate the static BE
export NTASKS_JEDI=$((layout*layout*6))  #number of processors for JEDI is determned by BE layout number
export SEND="YES"
export NLN="ln -sf"
export NCP="cp "

# orion specifc computing configuration; can be changed when debugging
export partition=orion       # debug
export qos=batch             # uegent, debug
export clocktime=55          # minutes
export cpus_per_task=1       # can increase to 2 when running out of memory
export cpus_per_task_jedi=2  # 2 is safer with layout=6
