#!/bin/bash

# Commands to run the second python file (average)

#SBATCH --partition=debug
#SBATCH --job-name=average_pi
#SBATCH --output=estimate_pi_average_complex.out
#SBATCH --error=estimate_pi_average_complex.err
#SBATCH --ntasks=1
#SBATCH --mem=1GB
# Need to build dependency on first job and afterrok means to run to completion with an exit code of zero
#SBATCH --dependency=afterok:8132

# run the python script to average the pi estimates from the previous job
python estimate_pi_average_complex.py