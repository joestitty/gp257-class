#!/bin/bash
# tell the shell to use the script (above)
#SBATCH --partition=preempt
#SBATCH --job-name=estimate_pi
# run the code 10000 times
#SBATCH --array=0-1000
# %A job_id %a tasks_id
#SBATCH --output=estimate_pi_complex_%A_%a.out
# write an error file to see info about errors during execution of job
#SBATCH --error=estimate_pi_%A_%a.err
# resubmit the job if the job fails (I need to make sure this works first before running lol)
#SBATCH --requeue
#SBATCH --ntasks=1
#SBATCH --mem=1GB

# Added this to set the environment variable that I will pass through, %05d for 5 character width with decimal format
task_id=$(printf "%05d" $SLURM_ARRAY_TASK_ID)

python estimate_pi_complex.py $task_id

