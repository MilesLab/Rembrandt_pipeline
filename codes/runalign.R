
library("optparse")
 
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="file containing list of sample names and file paths", metavar="character"),
    make_option(c("-a", "--align_results"), type="character", default="COVID_alignment_results", 
              help="output directory", metavar="character"),
    make_option(c("-x", "--index"), type="character", default="alignment_index/COVID_amplicon_index",
              help="location of index", metavar="character"),
    make_option(c("-o", "--output_meta"), type="character", default="out.meta.txt",
              help="output meta file", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

print(opt$file)
print(opt$align_results)

meta_file = read.csv(opt$file,header=F)
output_dir = as.character(opt$align_results)

colnames(meta_file)=c("Name","Path")
print(meta_file)

fullpath=as.character(meta_file$Path)

samples.names=as.character(meta_file$Name)

dir.create(output_dir)

outfilename=c()

for(i in 1:length(samples.names)){
bam_ouput = paste(output_dir,"/",samples.names[i],".bam", sep="")
Rsubread::align(index = as.character(opt$index),
                readfile1 = fullpath[i],
                output_file = bam_ouput,
                input_format = "FASTQ")
makefastq_command = paste("sh runmakefastqfiles.sh -d ", output_dir, " -f ", samples.names[i], sep="")

print(makefastq_command)
system(makefastq_command)

outfilename[i]=paste(output_dir, "/",samples.names[i],".onlycov.sorted.fq", sep="")
system(paste("ls", outfilename[i]))
}


meta_file = data.frame(meta_file,outfilename)

write.csv(meta_file, file=as.character(opt$output_meta), quote=F, row.names=F)

