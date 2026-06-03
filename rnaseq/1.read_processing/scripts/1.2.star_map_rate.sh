#!/bin/bash 

# the purpose of this script is to get map rate for STAR

#SBATCH --time=120:00:00  
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=15
#SBATCH --mem=128gb
#SBATCH -o ../log/rnaseq_snakemake.txt  
#SBATCH -A one_sc_default

d1=$(date +%s) 

working_dir="../output/2.star/"

# set working directory
cd $working_dir

pwd 
echo "Job started"

# merge output files into one
awk -f /storage/group/exd44/default/epr5208/STAR-2.7.11b/extras/scripts/mergeLogFinal.awk *Log.final.out > full_star_stats.txt

sleep 60
echo "Job ended"

d2=$(date +%s) 
sec=$(( ( $d2 - $d1 ) )) 
hour=$(echo - | awk '{ print '$sec'/3600}') 
echo Runtime: $hour hours \($sec\s\) 