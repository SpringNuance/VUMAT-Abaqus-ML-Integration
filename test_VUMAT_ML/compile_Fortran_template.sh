#!/bin/bash -l

module load python-data
module load intel-oneapi-compilers
export PATH=$PATH:/users/nguyenb5/.local/bin/
process_model -o ml_module.f90 LSTM