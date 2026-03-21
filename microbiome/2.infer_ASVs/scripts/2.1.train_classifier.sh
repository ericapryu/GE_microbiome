#!/bin/bash 

# the purpose of this script is to train the deblur classifer

#SBATCH --time=144:00:00  
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64gb
#SBATCH -o ../log/train_classifier.txt  
#SBATCH -A exd44_sc_default

d1=$(date +%s) 

working_dir="../"

# set working directory
cd $working_dir

pwd 
echo "Job started"

# load conda environment
module load anaconda3
source activate qiime2-amplicon-2024.2

# Extract reference reads
qiime feature-classifier extract-reads \
  --i-sequences data/silva-138-99-seqs.qza \
  --p-f-primer AGMGTTYGATYMTGGCTCAG \
  --p-r-primer GCTGCCTCCCGTAGGAGT \
  --p-trunc-len 270 \
  --p-min-length 100 \
  --p-max-length 400 \
  --o-reads data/ref-seqs.qza

# Train the classifier
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads data/ref-seqs.qza \
  --i-reference-taxonomy data/silva-138-99-tax.qza \
  --o-classifier data/trained_classifier.qza

sleep 60
echo "Job ended"

d2=$(date +%s) 
sec=$(( ( $d2 - $d1 ) )) 
hour=$(echo - | awk '{ print '$sec'/3600}') 
echo Runtime: $hour hours \($sec\s\) 