
library("optparse")
library(Biostrings)
 
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

print("Aligning reads to sequences")
outfilename=c()

for(i in 1:length(samples.names)){
sam_output = paste(output_dir,"/",samples.names[i],".sam", sep="")
Rsubread::align(index = as.character(opt$index),
                readfile1 = fullpath[i],
                output_file = sam_output,
                input_format = "FASTQ",output_format="SAM")



filepath=sam_output

print("Extracting N1_SARS_COV2 reads from SAM file",sep="")

outfq = paste(output_dir,"/",samples.names[i],".onlycov.sorted.fq", sep="")

outfilename[i]=outfq

counts = 0
  con = file(filepath, "r")
  while ( TRUE ) {
    line = readLines(con, n = 1)
    if ( length(line) == 0 ) {
      break
    }
    
    if (length(line) > 0){
    if(length(grep(x=line, pattern="N1_SARS_COV2")) > 0 & length(grep(x=line, pattern="@SQ")) == 0){
       splits=unlist(strsplit(line, split="\t"))
       l1 = paste("@",splits[1],sep="")
       l2 = paste(splits[10])
       l3 = "+"
       l4 = splits[11]
       
       if(splits[2]=="16"){
         l2 = as.character(reverseComplement(DNAString(l2)))
         l4 = reverse(l4)
       }
       if(counts==0){
       write(l1,file=outfq,append=F,sep="\n")
       counts = counts + 1
       }else{
       
       write(paste("@",l1,sep=""),file=outfq,append=T,sep="\n")
       counts = counts + 1
       }
       write(l2,file=outfq,append=T,sep="\n")
       write(l3,file=outfq,append=T,sep="\n")
       write(l4,file=outfq,append=T,sep="\n")

      if(counts %% 10000 == 0){
        print(paste(counts, "reads processed"))
      }

    }     
   }

    
}    
  
  close(con)
}

meta_file = data.frame(meta_file,outfilename)
write.csv(meta_file, file=as.character(opt$output_meta), quote=F, row.names=F)


