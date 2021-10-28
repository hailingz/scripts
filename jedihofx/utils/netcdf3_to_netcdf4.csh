#!/usr/bin/csh
###### convert netcdf3 file to netcdf4 format ####
###### 20211026 Hailing Zhang ########## #############
set input=$1
set output=$2
module load nco
nccopy -4 $input $output
