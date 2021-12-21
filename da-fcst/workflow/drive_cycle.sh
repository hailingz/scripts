#!/bin/sh
source  ./setup.sh

export SDATE=2021010400
export EDATE=2021010406

export CDATE=$SDATE
while (( $CDATE <= $EDATE )); do
  export yyyy=${CDATE:0:4}
  export mm=${CDATE:4:2}
  export dd=${CDATE:6:2}
  export hh=${CDATE:8:2}
  export PREDATE=$( date -u --date="-${assim_freq} hours ${CDATE:0:4}-${CDATE:4:2}-${CDATE:6:2} ${CDATE:8:2}" +%Y%m%d%H )
  export yyyymmdd_pre=${PREDATE:0:8}
  export hh_pre=${PREDATE:8:2}
  # run DA
  sh run_jedi.sh $CDATE
  # run the NWP model
  sh run_fv3.sh $CDATE
  # advance date
  export CDATE=$(date -u --date="${assim_freq} hours ${CDATE:0:4}-${CDATE:4:2}-${CDATE:6:2} ${CDATE:8:2}" +%Y%m%d%H )
done
