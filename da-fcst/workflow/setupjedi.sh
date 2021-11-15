#!/bin/csh -f

# set up JEDI DA
# H.Zhang 202111

source ./setup.sh

#--------- 1. set up experiment ---------------
set    oper   =  NBAM
setenv ROOPR     GnssroBnd$oper
setenv ROPP2D    0
setenv RADIO     0
setenv bkg       17
#setenv datause   gnss
setenv RES       384
@ RESS = ( $RES + 1 )
setenv RESS      $RESS
setenv layout      6 
@ NP = ( $layout * $layout  * 6  )
setenv NP $NP

#-------------- 1.1 edit your operator options here ---------
setenv errmodel         "NRL"
setenv threshold        4
setenv localization     2200km_0.58
set    srmethod         =  NBAM
setenv OPTS             'vertlayer:full use_compress:1 super_ref_qc:${srmethod} sr_steps:2'
setenv BackgroundCheck  "Background Check RONBAM"
setenv Ninter1          50
setenv Ninter2          25
setenv minimizer        DRPLanczos
#-------------- 1.1 edit your operator options here ---------

setenv DATA_DIR      ${TOP_DIR}/Data
setenv BUMP_name     bump${layout}_c${RES}_$localization
setenv FIX_path      ${DATA_DIR}/files

setenv radiodir      ${DATA_DIR}/obs/oper/PT6H
setenv rodir         ${DATA_DIR}/obs/gnssro_geoop_spire
setenv TEMPLATE_DIR  ${TOP_DIR}/template
#----------------
setenv CONVERT_RES   192
@ CONVERT_RESS = ( $CONVERT_RES + 1 )
setenv CONVERT_RESS $CONVERT_RESS
