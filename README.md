# Physiological relationship between host gene expression and the gut microbiome
This repository contains all scripts used to generate the results for "Physiological relationship between host gene expression and the gut microbiome." All analyses start in the same base directory. All analyses are conducted in Bash/Unix and R - all shell scripts were run in shell and all R markdowns were run in R. R scripts were submitted as Slurm batch jobs.

The main directory is `GE_microbiome\`. Within `GE_microbiome\`, there are sub-directories called `microbiome\` (microbiome processing and analysis), `rnaseq\` (gene expresssion processing and analysis), and `mic_rna_integration\` (gene expression-microbiome integration and analysis). All scripts are run from within each individual script directory.

Within `microbiome\`, there are directories `1.qc_host_decontam\`, `2.infer_ASVs\`, and `3.microbiome_analysis\`. Directories `1.qc_host_decontam\` and `2.infer_ASVs\` pertain to major microbiome data processing steps, whereas the bulk of analyses occurs in `3.microbiome_analysis\`. All three contain directories `data\`, `log\`, `output\`, and `scripts\`, and `3.microbiome_analysis\` also contains `figures\`. `1.qc_host_decontam\` contains the files `snakefile` and `host_decontam.yml` needed to run the snakemake pipeline. `1.qc_host_decontam\data\` contains the directories `raw\` and `refs\`. `raw\` contains raw microbiome sequences and `refs\` contains the human genome references used for filtering human read contaminants. `2.infer_ASVs\data\` contains the QIIME2 metadata file `manifest.txt`. `3.microbiome_analysis\data\` contains the metadata file `Gut_microbiome_metadata.tsv`. All data files except those specified here are not included in the repo due to size, but are included as supplemental tables in the publication or on SRA under BioProject PRJNA1311722.

Within `rnaseq\`, there are directories `1.read_processing\`, in which most RNA-seq data processing occurs, and `2.rnaseq_analysis`, in which most RNA-seq analysis occurs. Both directories contain directories `data\`, `log\`, `output\`, and `scripts\`, and `2.rnaseq_analysis\` also contains `figures\`. `1.read_processing\` contains the files `snakefile` and `STAR.yml` needed to run the snakemake pipeline. `1.read_processing\data\` contains the directories `raw\` and `STAR_genome\`. `raw\` contains raw RNA-seq data and `STAR_genome\` contains the human genome references used for aligning and mapping the reads. `2.rnaseq_analysis\` contains the metadata file `RNA_metadata.csv`. All data files except those specified here are not included in the repo due to size, but are included as supplemental tables in the publication or on SRA under BioProject PRJNA1444093.

Within `mic_rna_integration\`, there are directories `data\`, `log\`, `output\`, `scripts\`, and `figures\`. In `data\`, there are the files `PID_path_entrez.csv` and `protein_coding.txt`, which are used to assign entrez IDs to gene symbols from the PID database and to filter to protein coding genes, respectively. The KEGG pathway database used is not provided, as it is the paid version. 

Basic file structure:
```
GE_microbiome
|- README                           # Description of analysis scripts
|
|- microbiome/                      # Microbiome data processing and analyses
|       |- 1.qc_host_decontam/      # Microbiome decontamination pipeline 
|           |- data/                # Any data put into analyses
|           |- log/                 # Log for submitted batch jobs
|           |- output/              # Will contain output from scripts after they are run
|           |- figures/             # Will contain figures generated from scripts after they are run
|           |- scripts/             # Scripts to be run
|       |- 2.infer_ASVs/            # Microbiome ASV inference
|       |- 3.microbiome_analysis/   # Microbiome analysis scripts and output
|
|- RNAseq/                          # Gene expression processing and analyses
|       |- 1.read_processing/       # RNA-seq data processing
|       |- 2.rnaseq_analysis/       # Gene expression analyses
|
|- mic_rna_integration/             # Gene expression-microbiome integration analyses
+
```
Note: The structure outlined in `1.qc_host_decontam\` is similar in other processing and analyses folders (detailed above), but kept simple here for clarity.

All package info is in the R script `package_info.R`

## Table of contents
### Microbiome
1. Host decontamination
    - `1.1.host_decontam_snakemake_submission.sh` - snakemake pipeline submission script to filter host contaminant reads from microbiome data
    - `1.2.read_counts_per_step.sh` - read tracking through host decontamination steps
2. Infer ASVs
    - `2.1.train_classifier.sh` - training classifier in preparation for QIIME2
    - `2.2.deblur.sh` - ASV inference via deblur in QIIME2
3. Microbiome analysis
    - `3.1.qiime_to_phyloseq.Rmd` - generate phyloseq object from QIIME2 output
    - `3.2.pos_control.Rmd` - verify positive controls from sample processing 
    - `3.3.benchmark_crosscontam.Rmd` - check for cross contamination via extraction and PCR negative controls
    - `3.4.env_decontamination.Rmd` - remove potential environmental contamination 
    - `3.5.additionalQC_covariate.Rmd` - additional QC and covariate correction
    - `3.6.microbiome_characterization.Rmd` - examine metrics for standard microbiome characteristics (alpha and beta diversity)
    - `3.7.differential_abundance.Rmd` - perform differential abundance analysis with ALDEx2 to identify taxa that differ based on lifestyle
### RNA-seq
1. Read processing
    - `1.1.rnaseq_snakemake_submission.sh` - snakemake pipeline submission script to align and annotate RNA-seq data
    - `1.2.star_output_stats.Rmd` - output statistics from alignment
2. RNA-seq analysis
    - `2.1.cov_correction.Rmd` - covariate correction
    - `2.2.PCA_outlier_removal.Rmd` - outlier check and removal
    - `2.3.dream.Rmd` - differential gene expression analysis via dream
### GE-microbiome integration
- `1.overall_association.Rmd` - overall relationshp between gene expression and the microbiome via Procrustes
- `2.group_association.Rmd` - group-level relationship between gene expression and the microbiome via sparse-CCA
- `3.1.ind_association_prep.Rmd` - data preparation for elastic net
- `3.2.enet_run_submission_script.sh` - submission script for elastic net on intestine-wide data
- `3.2.enet_run.R` - elastic net for intestine-wide data
- `3.3.enet_run_region_submission_script.sh` - submission script for elastic net on regional data
- `3.3.enet_run_region.R` - elastic net for regional data
- `3.4.ind_association_analysis.Rmd` - analysis of elastic net output