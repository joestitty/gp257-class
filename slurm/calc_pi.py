import numpy as np

def calc_pi(n_terms):

    total_sum_sign = 1 # We need to initialize the variables to keep track of the sum and sign of each term
    total_sum = 0
    for i in range(n_terms): # loop through the specified number of terms
        # add the current term to the total sum
        total_sum += total_sum_sign /(2*i+1)
        # flip the sign of the next term
        total_sum_sign *= -1 
    # Return the final approximation of pi
    return 4 * total_sum

# specify the number of terms to use in the approximation
n_terms = 1000000
approx = calc_pi(n_terms) # Calculate the approximation of pi
print('Pi Approximation: ', approx)
