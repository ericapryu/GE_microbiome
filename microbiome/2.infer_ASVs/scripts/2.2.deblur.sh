#!/bin/bash 

# the purpose of this script is to run microbiome sequences through deblur

#SBATCH --time=144:00:00  
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64gb
#SBATCH -o ../log/deblur_out.txt  
#SBATCH -A exd44_sc_default

d1=$(date +%s) 

# set variables
working_dir="../"
OUT_DIR="output"
VIZ="${OUT_DIR}/visualization"
STATS="${OUT_DIR}/stats"
IMPORT="data/manifest.txt"
METADATA="data/Gut_microbiome_metadata.tsv"
CLASS="data/trained_classifier.qza"
THREADS=15
FWD="AGMGTTYGATYMTGGCTCAG"
RVS="GCTGCCTCCCGTAGGAGT"

# set working directory
cd $working_dir

pwd 
echo "Job started"

# make directories
mkdir $VIZ
mkdir $STATS

# load conda environment
module load anaconda3
source activate qiime2-amplicon-2024.2

# import sequences into qiime2
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $IMPORT \
  --output-path ${OUT_DIR}/1.PE-demux_all.qza \
  --input-format PairedEndFastqManifestPhred33V2

# visualize
qiime demux summarize \
  --i-data ${OUT_DIR}/1.PE-demux_all.qza \
  --o-visualization ${VIZ}/1.PE-demux_all.qzv

# trim with cutadapt
qiime cutadapt trim-paired \
    --p-cores $THREADS \
    --i-demultiplexed-sequences ${OUT_DIR}/1.PE-demux_all.qza \
    --p-front-f $FWD \
    --p-front-r $RVS \
    --p-minimum-length 100 \
    --p-match-adapter-wildcards \
    --p-discard-untrimmed \
    --o-trimmed-sequences ${OUT_DIR}/2.trimmed-PE-demux_all.qza \
    --verbose

# visualize
qiime demux summarize \
  --i-data ${OUT_DIR}/2.trimmed-PE-demux_all.qza \
  --o-visualization ${VIZ}/2.trimmed-PE-demux_all.qzv

# join reads
qiime vsearch merge-pairs \
  --i-demultiplexed-seqs ${OUT_DIR}/2.trimmed-PE-demux_all.qza \
  --o-merged-sequences ${OUT_DIR}/3.demux-merged.qza \
  --o-unmerged-sequences ${OUT_DIR}/3.5.unmerge_demux.qza \
  --verbose

qiime demux summarize \
  --i-data ${OUT_DIR}/3.demux-merged.qza \
  --o-visualization ${VIZ}/3.demux-merged.qzv

qiime demux summarize \
  --i-data ${OUT_DIR}/3.5.unmerge_demux.qza \
  --o-visualization ${VIZ}/3.5.unmerge_demux.qzv

# filter based on quality score
qiime quality-filter q-score \
  --i-demux ${OUT_DIR}/3.demux-merged.qza \
  --o-filtered-sequences ${OUT_DIR}/4.demux-joined-filtered.qza \
  --o-filter-stats ${STATS}/4.demux-joined-filter-stats.qza

 qiime metadata tabulate \
  --m-input-file ${STATS}/4.demux-joined-filter-stats.qza \
  --o-visualization ${STATS}/4.demux-joined-filter-stats.qzv

# deblur
qiime deblur denoise-16S \
  --p-jobs-to-start $THREADS \
  --i-demultiplexed-seqs ${OUT_DIR}/4.demux-joined-filtered.qza \
  --p-trim-length 270 \
  --p-min-reads 0 \
  --o-representative-sequences ${OUT_DIR}/5.rep-seqs-deblur.qza \
  --o-table ${OUT_DIR}/5.table-deblur.qza \
  --p-sample-stats \
  --o-stats ${STATS}/5.deblur-stats.qza \
  --verbose

qiime deblur visualize-stats \
  --i-deblur-stats ${STATS}/5.deblur-stats.qza \
  --o-visualization ${STATS}/5.deblur-stats.qzv

# make feature table
qiime feature-table summarize \
  --i-table ${OUT_DIR}/5.table-deblur.qza \
  --o-visualization ${VIZ}/5.table-deblur.qzv \
  --m-sample-metadata-file $METADATA

qiime feature-table tabulate-seqs \
  --i-data ${OUT_DIR}/5.rep-seqs-deblur.qza \
  --o-visualization ${VIZ}/5.rep-seqs-deblur.qzv

# generate tree
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences ${OUT_DIR}/5.rep-seqs-deblur.qza \
  --o-alignment ${OUT_DIR}/6.aligned-rep-seqs-deblur.qza \
  --o-masked-alignment ${OUT_DIR}/6.masked-aligned-rep-seqs-deblur.qza \
  --o-tree ${OUT_DIR}/6.unrooted-tree-deblur.qza \
  --o-rooted-tree ${OUT_DIR}/6.rooted-tree-deblur.qza

# assign taxonomy
qiime feature-classifier classify-sklearn \
  --i-classifier $CLASS \
  --i-reads ${OUT_DIR}/5.rep-seqs-deblur.qza \
  --o-classification ${OUT_DIR}/7.taxonomy-deblur.qza

qiime metadata tabulate \
  --m-input-file ${OUT_DIR}/7.taxonomy-deblur.qza \
  --o-visualization ${VIZ}/7.taxonomy-deblur.qzv

sleep 60
echo "Job ended"

d2=$(date +%s) 
sec=$(( ( $d2 - $d1 ) )) 
hour=$(echo - | awk '{ print '$sec'/3600}') 
echo Runtime: $hour hours \($sec\s\) 