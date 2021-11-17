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

To create the index, load in R and the *Rsubread* package and enter the following code.

```
library("Rsubread")
dir.create("alignment_index")
Rsubread::buildindex('alignment_index/COVID_amplicon_index',reference = covid_seqs_path)
```

With this code, we place the indices for the COVID amplicon into the *alignment_index* folder. I call the index, *COVID_amplicon_index*. Other names can be chosen however this is default for the pipeline.

## Running the Rembrandt Pipeline

There are 2 scripts to call.  

The first is *runalign.R*. The purpose of this script is to align the reads to the COVID sequence and create a fastq file of those reads aligning to the COVID sequences. There are 2 versions. The main version (running faster) requires samtools and bedtools in a Linux-based environment installed. The other version (in the OnlyR/) folder uses only R-based scripts to create the fastq file. This version runs much slower. 

It can be called using *Rscript*. To observe the arguments possible use the help argument as below.

```
Rscript codes/runalign.R --help
```

From there you obtain the following options:

Options:

        -f CHARACTER, --file=CHARACTER
                file containing list of sample names and file paths

        -a CHARACTER, --align_results=CHARACTER
                output directory

        -x CHARACTER, --index=CHARACTER
                location of index

        -o CHARACTER, --output_meta=CHARACTER
                output meta file

        -h, --help
                Show this help message and exit

The --file (-f) option is the path of the meta file that lists the fastq files that need to be processed. In -align_results(-a), the directory for the output is listed. The --index(-x) argument lists the alignment index for Rsubread and --output_meta (-o) is the meta file for the outputted results. 

The next script to run is generate_overlap_matrix.R. It uses information on Forward and Reverse barcodes to count how many reads align to each set of primers and discover matching Forward and Reverse barcode pairs as given in the overlap matrix. It can also be called using *Rscript* as below. 

To obtain the necessary options, we can use the -h or --help flag.

```
Rscript codes/generate_overlap_matrix.R -h
```

Options:
 
       -i CHARACTER, --input=CHARACTER
                path of input fasta file

        -b CHARACTER, --forward_barcodes=CHARACTER
                forward primer meta file

        -r CHARACTER, --reverse_barcodes=CHARACTER
                reverse primer meta file

        -o CHARACTER, --output_file=CHARACTER
                path to output file


## Questions, Comments, Concerns

An issue can be made at our Github repository. In addition, you can email me at jalal.siddiqui@osumc.edu


