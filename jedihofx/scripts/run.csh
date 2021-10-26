#!/bin/csh -f
#### THIS IS THE SCRIPT for running a single time JEDI HOFX ####
source  ./setup.csh
echo $TOP_DIR

setenv DATE           $1
setenv yyyy    `echo $DATE | cut -c 1-4`
setenv mm      `echo $DATE | cut -c 5-6`
setenv dd      `echo $DATE | cut -c 7-8`
setenv hh      `echo $DATE | cut -c 9-10`

setenv PREDATE       `$TOOL/da_advance_time.exe $DATE -6`
setenv yyyymmdd_pre  `echo $PREDATE | cut -c 1-8`
setenv hh_pre        `echo $PREDATE | cut -c 9-10`

setenv BGNDATE       `$TOOL/da_advance_time.exe $DATE -3`
setenv yyyy_b        `echo $BGNDATE | cut -c 1-4`
setenv mm_b          `echo $BGNDATE | cut -c 5-6`
setenv dd_b          `echo $BGNDATE | cut -c 7-8`
setenv hh_b          `echo $BGNDATE | cut -c 9-10`


setenv  rundir      ${TOP_DIR}/run/${EXPT}/${DATE}
if (! -d $rundir ) mkdir -p $rundir
cd $rundir
if (! -d log)      mkdir log
setenv  hofxout     ${rundir}/output/hofx
if (! -d ${hofxout}) mkdir -p ${hofxout}

setenv m3 `printf "%03i" ${bkg}`
setenv BKG_path ${DATA_DIR}/ens_c${RES}/enkfgdas.${yyyymmdd_pre}/${hh_pre}/mem${m3}/RESTART/

csh ${TEMPLATE_DIR}/template_hofx_yaml.csh  hofx.yaml 

csh  ${TEMPLATE_DIR}/template_job.csh job_${DATE}.csh  hofx   fv3jedi_hofx_nomodel.x
sbatch job_${DATE}.csh 
