import os
import random
import numpy as np
import sys

task_id = int(os.environ['SLURM_ARRAY_TASK_ID']) # grab the slurm_id
random.seed(task_id) # use task id to get a random number
trial_num = 10000 # number of trials to estimate pi

num_of_successes = 0 # start the count for number of trials that meet the criteria

for i in range(trial_num):
    x = np.random.random()
    y = np.random.random()
    if (x**2) + (y**2) <=1: # sum of squares
        num_of_successes += 1
        
pi_estimate = 4 * float(num_of_successes/trial_num) # calculate the estimate
filename = f"result_{task_id}.txt" # file name with task id
with open(filename, 'w') as f:
    f.write(str(pi_estimate)) # write the estimate
                 
