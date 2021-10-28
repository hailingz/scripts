#!/usr/bin/csh 
###### convert ioda1 file to ioda2 format ####
###### 20211026 Hailing Zhang ########## #############
set JEDIbuild=$your_jedi_build_directory
set input=$1
set output=$2
${JEDIbuild}/bin/ioda-upgrade.x  $input $output
