#!/bin/bash
if [ $# == 0 ]; then
  cat <<HELP_USAGE
  $0 param1 param2
  param1 number of repetitions
  param2 node label, can be stat or chpc
  param3 number of cores
  param4 parant folder
HELP_USAGE
  exit 0
fi

# if [ -d $4_mcf ]; then
#   echo "folder $4_mcf exists"
# else
#   mkdir $4_mcf
# fi

curr_timestamp=$(date -Iseconds)
folder=$4_KTHSE_${curr_timestamp}
mkdir $folder

for i in $(seq 1 1 $1); do
  # echo $i
  # sbatch -p chpc -q chpc --export=timestamp=$(date +"%Y-%m-%dT%H:%M:%S")_$i oracle_setting_parallel.job
  sbatch -N 1 -c $3 -p $2 -q $2 --export=parent_folder=$4,nrep=${i},np=$3,folder=$folder run_parallel.job
done