#!/bin/csh -f

### NOTE: this is a script to run jobs for JEDI hofx
########  H.Zhang 2021024

#--------- 1. set up experiment ---------------
setenv TOP_DIR   /work2/noaa/da/hailingz/work/newinstru/
setenv TOOL      "~/lib/"
setenv JEDIbin   /work/noaa/da/hailingz/jedi/build/fv3-bundle_20211022/bin
setenv DATE      $1
set    oper   =  NBAM
setenv ROOPR     GnssroBnd$oper  # default GNSSRO operator
setenv ROPP1D    1               # if use ropp1d operator
setenv ROPP2D    0               # if use ropp2d operator
setenv bkg       1               # temporary using ensemble as background
setenv RES       384             # fv3 background resolution
@ RESS = ( $RES + 1 )
setenv RESS      $RESS
setenv EXPT      test
setenv layout      6             # fv3 cube layout
@ NP = ( $layout * $layout  * 6  ) # computing resource
setenv NP $NP

#----------------- edit your operator options here ---------
setenv errmodel         "NRL"     # RO observation error
setenv threshold        4         # departure threshold
setenv srmethod        "NBAM"     # super r4efraction method
setenv OPTS             'vertlayer:full use_compress:1 super_ref_qc:NBAM sr_steps:2'
setenv BackgroundCheck  "Background Check RONBAM"
#------------------ edit your operator options here ---------

#-------------- runtime directories -------------------------
setenv DATA_DIR      ${TOP_DIR}/Data
setenv FIX_path      ${DATA_DIR}/files
setenv rodir         ${DATA_DIR}/ioda2
setenv TEMPLATE_DIR  ${TOP_DIR}/template
#-------------- runtime directories -------------------------
