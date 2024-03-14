#!/bin/bash -l

module load python-data
module load intel-oneapi-compilers

ifort -fPIC -I/projappl/project_2004956/fortran-tf-lib/fortran-tf-lib/tf_intel/include/fortran-tf \
      -c ml_module.f90 
ifort -shared -o libml_module.so ml_module.o