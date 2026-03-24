# Physiological relationship between host gene expression and the gut microbiome
This repository contains all scripts used to generate the results for "Physiological relationship between host gene expression and the gut microbiome." All analyses start in the same base directory. All analyses are conducted in Bash/Unix and R - all shell scripts were run in shell and all R markdowns were run in R. R scripts were submitted as Slurm batch jobs.

The main directory is `GE_microbiome\`. Within `GE_microbiome\`, there are sub-directories called `microbiome\` (microbiome processing and analysis), `rnaseq\` (gene expresssion processing and analysis), and `mic_rna_integration\` (gene expression-microbiome integration and analysis). All scripts are run from within each individual script directory.

Within `microbiome\`, there are directories `1.qc_host_decontam\`, `2.infer_ASVs\`, and `3.microbiome_analysis\`. Directories `1.qc_host_decontam\` and `2.infer_ASVs\` pertain to major microbiome data processing steps, whereas the bulk of analyses occurs in `3.microbiome_analysis\`. All three contain directories `data\`, `log\`, `output\`, and `scripts\`, and `3.microbiome_analysis\` also contains `figures\`. `1.qc_host_decontam\` contains the files `snakefile` and `host_decontam.yml` needed to run the snakemake pipeline. `1.qc_host_decontam\data\` contains the directories `raw\` and `refs\`. `raw\` contains raw microbiome sequences and `refs\` contains the human genome references used for filtering human read contaminants. `2.infer_ASVs\data\` contains the QIIME2 metadata file `manifest.txt`. `3.microbiome_analysis\data\` contains the metadata file `Gut_microbiome_metadata.tsv`. All data files except those specified here are not included in the repo due to size, but are included as supplemental tables in the publication or on SRA under BioProject PRJNAXXXXXXXXXXX.

Within `rnaseq\`, there are directories `1.read_processing\`, in which most RNA-seq data processing occurs, and `2.rnaseq_analysis`, in which most RNA-seq analysis occurs. Both directories contain directories `data\`, `log\`, `output\`, and `scripts\`, and `2.rnaseq_analysis\` also contains `figures\`. `1.read_processing\` contains the files `snakefile` and `STAR.yml` needed to run the snakemake pipeline. `1.read_processing\data\` contains the directories `raw\` and `STAR_genome\`. `raw\` contains raw RNA-seq data and `STAR_genome\` contains the human genome references used for aligning and mapping the reads. `2.rnaseq_analysis\` contains the metadata file `RNA_metadata.csv`. All data files except those specified here are not included in the repo due to size, but are included as supplemental tables in the publication or on SRA under BioProject PRJNAXXXXXXXXXXX.

Within `mic_rna_integration\`, there are directories `data\`, `log\`, `output\`, `scripts\`, and `figures\`. In `data\`, there are the files `PID_path_entrez.csv` and `protein_coding.txt`, which are used to assign entrez IDs to gene symbols from the PID database and to filter to protein coding genes, respectively. The KEGG pathway database used is not provided, as it is the paid version. 

```
GE_microbiome
|- README		# Description of analysis scripts
|
|- data/		# Any data put into analyses - may be raw or processed (note: not version controlled currently due to size)
|    |- fwd/		          
|    |- filt_path/
|
|- output/		# Will contain output from scripts after they are run
|
|- figures/		# Will contain figures generated from scripts after they are run
+
```

All package info is in the R script `package_info.R`

## Table of contents
### Microbiome
1. Host decontamination
    - `1.1.host_decontam_snakemake_submission.sh`
    - `1.2.read_counts_per_step.sh`
2. Infer ASVs
3. Microbiome analysis
### RNA-seq


1. `oral_phyloseq.Rmd` - clean 16S rRNA gene amplicon sequence data and generate phyloseq object
2. `decontam.Rmd` - remove potential contaminants
3. `qc.Rmd` - additional QC and cleaning of the phyloseq object
4. `extraction_comparison.Rmd` - compare Qiagen and PowerSoil extraction kit data
5. `microbiome_characterization.Rmd` - examine metrics for standard microbiome characteristics (alpha and beta diversity)
6. `random_forest.Rmd` - use Random Forests to predict lifestyle based on lifestyle survey and microbiome data
7. `differential_abundance.Rmd` - perform differential abundance analysis with ALDEx2 to identify taxa that differ based on lifestyle
8. `microbiome_trend.Rmd` - perform trend test on all genera to see which microbial abundances follow the lifestyle trend
9. `CCA.Rmd` - conduct CCA to identify which specific lifestyle factors correlate with microbiome composition
10. `taxa_lifestyle.Rmd` - identify significant associations between specific lifestyle factors and DA microbes identified from the trend test.
11. `picrust2_prep.Rmd` - prepping data for PICRUSt2
12. `picrust_stratified.sh` (shell) - run stratified version of PICRUSt2 to predict pathway abundances.
13. `picrust_analysis.Rmd` - analyze PICRUSt2 output. All PICRUSt2 output from `picrust_stratified.sh` is assumed to be stored in its own directory `picrust2_qiagen_output\`
14. `network_analysis.Rmd` - conduct network analysis of the microbiome using SparCC
15. `gut_oral_comparison.Rmd` - examine the relationship between the oral and gut microbiomes
