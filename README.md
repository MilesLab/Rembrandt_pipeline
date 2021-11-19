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

The --file (-f) option is the path of the meta file that lists the fastq files that need to be processed. This file is a CSV file in the following format:

test,./testdata.fq

The first entry is the sample name and the second entry is the path to the file. 

In -align_results(-a), the directory for the output is listed. The --index(-x) argument lists the alignment index for Rsubread. 

The --output_meta (-o) argument is the meta file for the outputted results. This is a CSV file in the following format:

|Name|Path         |outfilename                                   |
|----|-------------|----------------------------------------------|
|test|./testdata.fq|COVID_alignment_results/test.onlycov.sorted.fq|

The *outfilename* column contains the location of the fastq file containing only the COVID aligned sequences. This file path will be needed for the next steps. 

As an example, we can enter the following code for the test data.

```
Rscript runalign.R -f test.meta.txt -a COVID_alignment_results -x alignment_index/COVID_amplicon_index -o test.meta.output.txt
```

This will result in the meta file for the outputted results and the fastq file of the COVID aligned sequences as above. 

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
 
        -s CHARACTER, --start_point=CHARACTER
                start point in primer sequence (default: 14)
 
        -t CHARACTER, --end_point=CHARACTER
                end point in primer sequence (default: 26)
 
        -h, --help
                Show this help message and exit

The --input (-i) option is the path of the input fastq file that contains the COVID aligned results. 

--forward-barcodes (-b) contains the path of the CSV file containing the forward primer information. The CSV file for the forward barcodes is attached in the data/ folder.  The file must be formatted as such. The top 15 barcode primers are as below:

|Forward.Primer.Name|Sequence                                              |
|-------------------|------------------------------------------------------|
|COV-N1-FOR-BC001   |TGTAAAACGACGGCCAGTCCTGAACCGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC002   |TGTAAAACGACGGCCAGTTATCCAGTGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC003   |TGTAAAACGACGGCCAGTGAGATAACGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC004   |TGTAAAACGACGGCCAGTACACAGGCGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC005   |TGTAAAACGACGGCCAGTAGCCTACTGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC006   |TGTAAAACGACGGCCAGTATGCACCTGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC007   |TGTAAAACGACGGCCAGTCATGGAATGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC008   |TGTAAAACGACGGCCAGTCAGTTCCAGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC009   |TGTAAAACGACGGCCAGTCCGTATATGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC010   |TGTAAAACGACGGCCAGTGCTGAAGAGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC011   |TGTAAAACGACGGCCAGTTCTCGCCTGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC012   |TGTAAAACGACGGCCAGTCGCAAGCTGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC013   |TGTAAAACGACGGCCAGTTATCTGTGGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC014   |TGTAAAACGACGGCCAGTGCCGAATGGACCCCAAAATCAGCGAAATGCACCCCG|
|COV-N1-FOR-BC015   |TGTAAAACGACGGCCAGTTACTGCAGGACCCCAAAATCAGCGAAATGCACCCCG|

--reverse-barcodes (-r) contains the path of the CSV file containing the reverse primer information. Likewise, we have the CSV file for the reverse barcodes in the data/ folder as well. The top 15 barcode primers for those are also as below:

|Reverse.Primer.Name|Sequence                                              |
|-------------------|------------------------------------------------------|
|COV-N1-REV-BC001   |CAGGAAACAGCTATGACTCCATTCAGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC002   |CAGGAAACAGCTATGACATACGGATGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC003   |CAGGAAACAGCTATGACATATGGGAGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC004   |CAGGAAACAGCTATGACCATGCCATGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC005   |CAGGAAACAGCTATGACCCGTGAGAGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC006   |CAGGAAACAGCTATGACATTGTCCAGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC007   |CAGGAAACAGCTATGACGCACCAGAGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC008   |CAGGAAACAGCTATGACTTACCGGGGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC009   |CAGGAAACAGCTATGACCTTAGTGGGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC010   |CAGGAAACAGCTATGACCGCATAGTGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC011   |CAGGAAACAGCTATGACGAAGCGATGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC012   |CAGGAAACAGCTATGACTACCTACGGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC013   |CAGGAAACAGCTATGACACAAACTGGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC014   |CAGGAAACAGCTATGACCGTTGAGGGCGTTCTCCATTCTGGTTACTGCCAGTTG|
|COV-N1-REV-BC015   |CAGGAAACAGCTATGACCCTATCAGGCGTTCTCCATTCTGGTTACTGCCAGTTG|

--start_point (-s) and --end_point (-t) are the starting and end points in the primer sequences that you wish to search for. Usually this incorporates the necessary barcodes + additional sequences.

--output_file (-o) is the path of the overlap matrix that describes how the forward and reverse barcodes overlap with each other on the COVID-aligned reads. An example is shown below.

|FIELD1|COV-N1-REV-BC001|COV-N1-REV-BC022                              |COV-N1-REV-BC048|COV-N1-REV-BC062|COV-N1-REV-BC096|
|------|----------------|----------------------------------------------|----------------|----------------|----------------|
|COV-N1-FOR-BC011|55              |29                                            |30              |70              |93              |
|COV-N1-FOR-BC058|31              |16                                            |22              |32              |4               |
|COV-N1-FOR-BC060|29              |27                                            |24              |84              |19              |
|COV-N1-FOR-BC080|27              |31                                            |19              |46              |51              |
|COV-N1-FOR-BC094|53              |92                                            |5               |82              |84              |

As an example, we can run the following for the test results.

```
Rscript generate_overlap_matrix.R -i COVID_alignment_results/test.onlycov.sorted.fq -b Forward.Primer.csv -r Reverse.Primer.csv -o test.overlap.mat.csv
```
## Questions, Comments, Concerns

An issue can be made at our Github repository. In addition, you can email me at jalal.siddiqui@osumc.edu


