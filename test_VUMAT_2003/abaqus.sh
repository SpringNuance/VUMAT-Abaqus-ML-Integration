#!/bin/bash -l
# Author: Xuan Binh
#SBATCH --job-name=VUMAT
#SBATCH --error=abaqus.err
#SBATCH --output=abaqus.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:15:00
#SBATCH --partition=test
#SBATCH --account=project_2004956
#SBATCH --mail-type=ALL
#SBATCH --mail-user=binh.nguyen@aalto.fi

unset SLURM_GTIDS

# Old Intel compilers
# module load intel-oneapi-compilers-classic
module load intel-oneapi-compilers
# module load gcc

module load abaqus

cd $PWD

CPUS_TOTAL=$(( $SLURM_NTASKS*$SLURM_CPUS_PER_TASK ))

#abq2022 job=geometry input=geometry.inp cpus=$CPUS_TOTAL -verbose 2 interactive

abaqus job=uniaxial_tension_vumat input=uniaxial_tension_vumat.inp user=code_2003 cpus=$CPUS_TOTAL -verbose 2 interactive