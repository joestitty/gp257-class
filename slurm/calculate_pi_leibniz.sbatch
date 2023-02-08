#!/bin/sh

# Slurm Batch Script for Pi Calculation

#SBATCH --partition=debug
#SBATCH --time=2:00:00
#SBATCH --mem=1024
#SBATCH --cpus-per-task=1

# call the python function to run with these parameters
python calc_pi.py
