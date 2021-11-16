# Rembrandt_pipeline

The repository contains code for running the Rembrandt pipeline.  This will consist of 2 steps. The first involves aligning the reads to the COVID genome and extraction of reads aligned to COVID. The second step involves splitting the COVID-aligned reads to the different barcodes.

## Setting up the environment

In order to run the pipeline the user will need the following installed:

*R (version 3.6 or greater)*

*Samtools (1.2 or greater)*

*Bedtools* 

The following R packages need to be installed:

*optparse*

*Rsubread*

*ShortRead*

On the R console, **optparse** can be installed as follows:

```
install.packages("optparse")
```

**RSubread** can be installed as follows:

```
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("Rsubread")
```

**ShortRead** can be installed as follows:

```
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("ShortRead")
```

## Generating the COVID-19 Index

To run the analysis, it is necessary to generate the COVID-19 amplicon index. This is done using files from the data/ folder.

