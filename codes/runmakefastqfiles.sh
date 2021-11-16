#!/bin/bash
while getopts d:f: option;
   do
      case "${option}" in
         d) x_dir=$OPTARG;;
         f) x=$OPTARG;;
      esac
   done


#echo ${x}
x_path="${x_dir}/${x}.bam"
#echo ${x_path}

echo "Importing file ${x_path} into samtools"
samtools view ${x_path} | grep "N1_SARS_COV2" > ${x}_seqs.sam
samtools view -H ${x_path} > ${x}_header.sam
cat ${x}_header.sam ${x}_seqs.sam > ${x_dir}/${x}.onlycov.sam
rm ${x}_seqs.sam
rm ${x}_header.sam

echo "Only reads aligning to N1_SARS_COV2 extracted"

samtools sort ${x_dir}/${x}.onlycov.sam -o ${x_dir}/${x}.onlycov.sorted.bam
rm ${x_dir}/${x}.onlycov.sam
bedtools bamtofastq -i ${x_dir}/${x}.onlycov.sorted.bam -fq ${x_dir}/${x}.onlycov.sorted.fq

echo "BAM file converted into fastq file ${x_dir}/${x}.onlycov.sorted.fq"


