#!/bin/sh
source  ./setup.sh

export SDATE=2021010400
export EDATE=2021010400

export CDATE=$SDATE
while [ $CDATE -le $EDATE ]; do

#sh run_fv3.sh $CDATE
export CDATE=$($NDATE $assim_freq $CDATE)
export yyyy=`echo $CDATE | cut -c 1-4`
export mm=`echo $CDATE | cut -c 5-6`
export dd=`echo $CDATE | cut -c 7-8`
export hh=`echo $CDATE | cut -c 9-10`
export PREDATE=$($NDATE -$assim_freq $CDATE)
export yyyymmdd_pre=`echo $PREDATE | cut -c 1-8`
export hh_pre=`echo $PREDATE | cut -c 9-10`
sh run_jedi.sh $CDATE
done
