#!/bin/bash 

# The purpose of this script is to separate the qiagen pilot mapped and unmapped reads into separate directories

#SBATCH --time=120:00:00  
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=15
#SBATCH --mem=128gb
#SBATCH -o ../log/rnaseq_snakemake.txt  
#SBATCH -A one_sc_default

d1=$(date +%s) 

working_dir="../"

# set working directory
cd $working_dir

pwd 
echo "Job started"

# load conda environment
module load anaconda3
source activate snakemake

# run snakemake
snakemake --use-conda --cores 15 -p 

sleep 60
echo "Job ended"

d2=$(date +%s) 
sec=$(( ( $d2 - $d1 ) )) 
hour=$(echo - | awk '{ print '$sec'/3600}') 
echo Runtime: $hour hours \($sec\s\) 