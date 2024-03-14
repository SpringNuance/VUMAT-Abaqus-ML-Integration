#!/bin/bash -l
# Author: Xuan Binh
#SBATCH --job-name=VUMAT
#SBATCH --error=abaqus.err
#SBATCH --output=abaqus.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=30G
#SBATCH --partition=small
#SBATCH --account=project_2004956
#SBATCH --mail-type=ALL
#SBATCH --mail-user=binh.nguyen@aalto.fi

unset SLURM_GTIDS

# Old Intel compilers
module load intel-oneapi-compilers-classic
# module load intel-oneapi-compilers
# module load gcc

# Loading intel MPI
module load openmpi

module load abaqus
module load python-data


cd $PWD

CPUS_TOTAL=$(( $SLURM_NTASKS*$SLURM_CPUS_PER_TASK ))

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PWD}:/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/tensorflow/lib:/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/tf_intel/lib64

# oneDNN custom operations are on. 
# You may see slightly different numerical results due to floating-point round-off errors from different computation orders. 
# To turn them off, set the environment variable 

export TF_ENABLE_ONEDNN_OPTS=0

# Default path of abaqus_v6.env
# /appl/soft/eng/simulia/EstProducts/2023/linux_a64/SMA/site/lnx86_64.env

# process_model -o LSTM_fortran.f90 LSTM

# Compiling the ML module for making prediction in subroutine
./compile_ML_module.sh

# python add_CWD.py "abaqus_v6.env" $PWD

rm *.lck

abaqus job=uniaxial_tension_vumat input=uniaxial_tension_vumat.inp user=code_binh cpus=$CPUS_TOTAL double=both output_precision=full -verbose 2 interactive