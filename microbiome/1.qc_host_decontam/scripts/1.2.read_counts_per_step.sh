#!/bin/bash 

# the purpose of this script is to extract read info for each step of the human read removal process

#SBATCH --time=2:00:00  
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10gb
#SBATCH -o ../log/read_counts_per_step_log.txt  
#SBATCH -A exd44_sc_default

d1=$(date +%s) 

working_dir="../"
raw_dir="data/raw"
bowtie_map_dir="output/2.bowtie2/3.fastq/mapped"
bowtie_unmap_dir="output/2.bowtie2/3.fastq/unmapped"
snap_map_dir="output/3.snap/3.fastq/mapped"
snap_unmap_dir="output/3.snap/3.fastq/unmapped"
read_count_dir="output/5.read_count"

# set working directory
cd $working_dir

pwd 
echo "Job started"

# make output dir
mkdir $read_count_dir

#####  total number of reads sequenced from raw files
# add read counts to the file
for filename in ${raw_dir}/*.fastq.gz
do
echo $(zcat $filename|wc -l)/4|bc >> ${read_count_dir}/raw_read_count
done

# get list of columns
echo ${raw_dir}/*.fastq.gz > ${read_count_dir}/raw_filename


#####  total number of mapped reads post bowtie2
# add read counts to the file
for filename in ${bowtie_map_dir}/*.fastq
do
echo $(cat $filename|wc -l)/4|bc >> ${read_count_dir}/bowtie_mapped_read_count
done

# get list of columns
echo ${bowtie_map_dir}*.fastq > ${read_count_dir}/bowtie_mapped_filename


#####  total number of unmapped reads post bowtie2
# add read counts to the file
for filename in ${bowtie_unmap_dir}/*.fastq
do
echo $(cat $filename|wc -l)/4|bc >> ${read_count_dir}/bowtie_unmapped_read_count
done

# get list of columns
echo ${bowtie_unmap_dir}/*.fastq > ${read_count_dir}/bowtie_unmapped_filename


#####  total number of mapped reads post snap
# add read counts to the file
for filename in ${snap_map_dir}/*.fastq
do
echo $(cat $filename|wc -l)/4|bc >> ${read_count_dir}/snap_mapped_read_count
done

# get list of columns
echo ${snap_map_dir}/*.fastq > ${read_count_dir}/snap_mapped_filename


#####  total number of retained (unmapped) reads post snap
# add read counts to the file
for filename in ${snap_unmap_dir}/*.fastq
do
echo $(cat $filename|wc -l)/4|bc >> ${read_count_dir}/snap_unmapped_read_count
done

# get list of columns
echo ${snap_unmap_dir}/*.fastq > ${read_count_dir}/snap_unmapped_filename

sleep 60
echo "Job ended"

d2=$(date +%s) 
sec=$(( ( $d2 - $d1 ) )) 
hour=$(echo - | awk '{ print '$sec'/3600}') 
echo Runtime: $hour hours \($sec\s\) 