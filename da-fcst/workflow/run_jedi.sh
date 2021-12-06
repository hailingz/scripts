#!/bin/sh -f
source  ./setupjedi.sh
export  rundir=${TOP_DIR}/run/${EXPT}/${CDATE}/${DAmethod}

if [ ! -d $rundir ]; then mkdir -p $rundir; fi
cd $rundir 
if [ ! -d log ]; then mkdir log; fi
export  hofxout=${rundir}/output/hofx
export  analysisout=${rundir}/output/RESTART
if [ ! -d ${hofxout} ]; then mkdir -p ${hofxout}; fi
if [ ! -d ${analysisout} ]; then  mkdir -p ${analysisout}; fi

if [ $CDATE > $INIT_DATE ]; then
  export BKG_path=${TOP_DIR}/run/${EXPT}/${PREDATE}/atmos/RESTART
else
  export BKG_path=${DATA_DIR}/ens_c${RES}/enkfgdas.${yyyymmdd_pre}/${hh_pre}/mem001/RESTART
fi
export ENS_path=${DATA_DIR}/ens_c${RES}/enkfgdas.${yyyymmdd_pre}/${hh_pre}
sh ${TEMPLATE_DIR}/template_${DAmethod}_yaml.sh "${OPTS[@]}"
ln -sf ${BUMP_DIR}/${BUMP_name} . 
sh  ${TEMPLATE_DIR}/template_${DAmethod}_job.sh job_${CDATE}.sh  ${DAmethod}  fv3jedi_var.x
sbatch job_${CDATE}.sh 
sh ${SCRIPT_DIR}/checkfile.sh ${analysisout}/${yyyy}${mm}${dd}.${hh}0000.fv_core.res.tile1.nc
sh ${SCRIPT_DIR}/checkfile.sh ${analysisout}/${yyyy}${mm}${dd}.${hh}0000.fv_core.res.tile2.nc
sh ${SCRIPT_DIR}/checkfile.sh ${analysisout}/${yyyy}${mm}${dd}.${hh}0000.fv_core.res.tile3.nc
sleep 60
