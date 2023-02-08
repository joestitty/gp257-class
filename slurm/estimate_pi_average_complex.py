import glob
import os 

list_of_files = glob.glob("result*.txt") # find all files with the same pattern "result*.txt", list of filenames

sum_val = 0 
for name_of_file in list_of_files: # loop through the filenames
    with open(name_of_file, 'r') as f: # open each file with a read
        estimate = float(f.readline().strip()) # take each output file, read the first output line, strip whitespaces, convert to float
        sum_val += estimate # sum up all the estimates

average = sum_val / len(list_of_files) # take average

with open("result2.txt", 'w') as f: # write to the filename
    f.write(str(average)) #content in the write file
       


