# some simple instructions for cylc
#  this is specifically for Orion


# put this in your ~/.bash_profile or ~/.profile
CYLC_HOME=/home/bruston/.local/share/cylc
export PATH=${CYLC_HOME}/bin:$PATH


# recommend over-riding some defaults in cylc global config
mkdir ~/.cylc
vi ~/.cylc/global.rc

# add this to ~/.cylc/global.rc
process pool size = 4
[monitor]
   sort order = alphanumeric

[hosts]
   [[localhost]]
      work directory = /work/noaa/da/$USER/cylc-run
      run directory = /work/noaa/da/$USER/cylc-run


# the experiment control file is suite.rc
#  move this to a directory to register it
#  modify email address and paths to codes
#   and scripts used to run system
#   modify the starting dates

# the full cylc manual can be found here:
# https://cylc.github.io/cylc-doc/stable/html/index.html

# register the suite
cylc reg jedi.run.experiment.name  $PWD


# to run the suite
cylc run jedi.run.experiment.name


# monitor (once)
cylc mon --once jedi.run.experiment.name


# shut down
cylc shutdown -k jedi.run.experiment.name

# restart
cylc restart jedi.run.experiment.name


# view error log
cylc log -f e jedi.run.experiment.name  [task]  [time]
