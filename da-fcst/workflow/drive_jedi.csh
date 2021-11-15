#!/bin/csh -f
source  ./setupjedi.csh

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
setenv  analysisout ${rundir}/output/analysis
if (! -d ${hofxout}) mkdir -p ${hofxout}
if (! -d ${analysisout} )  mkdir -p ${analysisout}

setenv ENS_path   ${DATA_DIR}/ens_c${RES}/enkfgdas.${yyyymmdd_pre}/${hh_pre}
setenv m3 `printf "%03i" ${bkg}`
setenv BKG_path ${DATA_DIR}/ens_c${RES}/enkfgdas.${yyyymmdd_pre}/${hh_pre}/mem${m3}/RESTART/
csh ${TEMPLATE_DIR}/template_3dhyb_yaml.csh  3dhyb.yaml 

ln -sf ${DATA_DIR}/${BUMP_name} .
csh  ${TEMPLATE_DIR}/template_jedi_job.csh job_${DATE}.csh    3dhyb  fv3jedi_var.x
sbatch job_${DATE}.csh 
