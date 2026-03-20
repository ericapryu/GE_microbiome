#!/bin/bash 

# The purpose of this script is to run enet with each intestinal region

#SBATCH --time=120:00:00  
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=18
#SBATCH --mem=160gb
#SBATCH -o ../log/enet_indiv_region.txt 
#SBATCH -A exd44_sc_default 

d1=$(date +%s) 

# load conda environment
module load r/4.4.2

# run R script
Rscript --max-ppsize=500000 3.3.enet_run_region.R

sleep 60
echo "Job ended"

d2=$(date +%s) 
sec=$(( ( $d2 - $d1 ) )) 
hour=$(echo - | awk '{ print '$sec'/3600}') 
echo Runtime: $hour hours \($sec\s\) 