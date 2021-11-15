echo "generating job script"

set jobname=$1
set yaml=$2
set EXE=$3

cat > $jobname  <<EOF
#!/usr/bin/bash
#-------------------------------------------------------------------------------
#SBATCH --job-name=$3
#SBATCH -A da-cpu
#SBATCH -p orion
#SBATCH -q batch
#SBATCH --ntasks $NP
#SBATCH --cpus-per-task=1
#SBATCH -t 80:00
#SBATCH --output=stdout_${DATE}.%j
#-------------------------------------------------------------------------------
source /etc/bashrc
module purge
export JEDI_OPT=/work/noaa/da/grubin/opt/modules
module use -a $JEDI_OPT/modulefiles/core
module load jedi/gnu-openmpi
module unload fckit
module load ecbuild/jcsda-3.3.2.jcsda3
module load eckit/jcsda-1.11.6.jcsda2
module list
ulimit -s unlimited
ulimit -v unlimited

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE
export OOPS_DEBUG=1
export OOPS_TRACE=1

#-------------------------------------------------------------------------------
 srun --ntasks=$NP --cpu_bind=core --distribution=block:block ${JEDIbin}/${EXE} ${yaml}.yaml log/log_${yaml}
#-------------------------------------------------------------------------------
EOF
