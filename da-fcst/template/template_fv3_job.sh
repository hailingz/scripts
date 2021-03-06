cat > job.sh <<EOF
#!/usr/bin/bash
#-------------------------------------------------------------------------------
#SBATCH --job-name=$1
#SBATCH -A da-cpu
#SBATCH -p orion
#SBATCH -q batch
#SBATCH --nodes=$NNODE
#SBATCH --tasks-per-node=$TASKS_PER_NODE
#SBATCH --cpus-per-task=1
#SBATCH --exclusive
#SBATCH -t 40:00
#SBATCH -o fcst.out
#SBATCH -e fcst.error
#-------------------------------------------------------------------------------

ulimit -s unlimited
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=1024M
export HOMEgfs=$HOMEgfs
. /work/noaa/da/cmartin/noscrub/UFO_eval/global-workflow/ush/load_fv3gfs_modules.sh
module use /work/noaa/da/cmartin/noscrub/UFO_eval/global-workflow/modulefiles
module load module_base.orion
module list

srun --ntasks=$NTASKS_FV3  ${FCSTEXECDIR}/${FCSTEXEC}
EOF

