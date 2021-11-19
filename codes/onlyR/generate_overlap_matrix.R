
library("optparse")
 
option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="path of input fasta file", metavar="character"),
    make_option(c("-b", "--forward_barcodes"), type="character", default="Forward.Primer.csv", 
              help="forward primer meta file", metavar="character"),
    make_option(c("-r", "--reverse_barcodes"), type="character", default="Reverse.Primer.csv",
              help="reverse primer meta file", metavar="character"),
    make_option(c("-o", "--output_file"), type="character", default="out.csv",
              help="path to output file", metavar="character"),
   make_option(c("-s", "--start_point"), type="integer", default=14,
              help="start point in primer sequence (default: 14)", metavar="character"),
   make_option(c("-t", "--end_point"), type="integer", default=26,
              help="end point in primer sequence (default: 26)", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
print(opt$input)
print(opt$forward_barcodes)
print(opt$reverse_barcodes)

startp = opt$start_point
endp = opt$end_point


file_path1 = as.character(opt$input)


## Make sure you call the library
library(Rsubread)
library(ShortRead)
library(pheatmap)

file1 = ShortRead::FastqStreamer(file_path1)

reads.f1 = yield(file1)
#reads.f2 = yield(file2)

sequences.f1 = reads.f1@sread
#sequences.f2 = reads.f2@sread

rc.sequences.f1 = reverseComplement(sequences.f1)
#rc.sequences.f2 = reverseComplement(sequences.f2)

seq.f1 = as.character(sequences.f1)
#seq.f2 = as.character(sequences.f2)

rc.seq.f1 = as.character(rc.sequences.f1)
#rc.seq.f2 = as.character(rc.sequences.f2)


Forward.Primer.Info = read.csv(file=as.character(opt$forward_barcodes))
Reverse.Primer.Info = read.csv(file=as.character(opt$reverse_barcodes))

print(Forward.Primer.Info)

print(Reverse.Primer.Info)


primers.sequence = c(as.character(Forward.Primer.Info$Sequence),
                     as.character(Reverse.Primer.Info$Sequence))
names(primers.sequence) = c(as.character(Forward.Primer.Info$Forward.Primer.Name),
                            as.character(Reverse.Primer.Info$Reverse.Primer.Name))

print(primers.sequence)
print(names(primers.sequence))

spool.1.sample.seqs = seq.f1
spool.2.sample.seqs = rc.seq.f1
start.point = startp
end.point = endp


#### function to obtain primer counts
getPrimerCounts <- function(spool.1.sample.seqs,spool.2.sample.seqs,
                            start.point,end.point){
read1.primer.list = list()
read2.primer.list = list()

for(j in 1:length(primers.sequence)){
  select.primer = primers.sequence[j]
  
  print(names(primers.sequence)[j])
  
  print(substr(select.primer,start.point,end.point))
  
  read1.primer.list[[j]] = grep(pattern = substr(select.primer,start.point,end.point),
                                x=spool.1.sample.seqs)
  print(length(read1.primer.list[[j]]))
  read2.primer.list[[j]] = grep(pattern = substr(select.primer,start.point,end.point),
                                x=spool.2.sample.seqs)
  print(length(read2.primer.list[[j]]))
  
}
rm(j)

names(read1.primer.list)= names(primers.sequence)
names(read2.primer.list)= names(primers.sequence)

read1.lens = unlist(lapply(read1.primer.list, function(x){length(x)}))
read2.lens = unlist(lapply(read2.primer.list, function(x){length(x)}))

counts.mate1 = c(read1.lens)
counts.mate2 = c(read2.lens)


primer.counts = data.frame(counts.mate1, counts.mate2)

getPrimerCounts = list(read1.primer.list=read1.primer.list,
                       read2.primer.list=read2.primer.list,
                       primer.counts=primer.counts)

return(getPrimerCounts)

}


primer.counts.read1 = getPrimerCounts(spool.1.sample.seqs = seq.f1,
                                      spool.2.sample.seqs = rc.seq.f1,
                                      start.point = startp,
                                      end.point = endp)


#### We will design a function to get the overlap matrix

r1.list = primer.counts.read1$read1.primer.list
r2.list = primer.counts.read1$read2.primer.list

names.r1.list = names(r1.list)
names.r2.list = names(r2.list)

primer.overlap = matrix(nrow = length(names.r1.list),
                        ncol = length(names.r2.list))

rownames(primer.overlap)=names.r1.list
colnames(primer.overlap)=names.r2.list

for(i in 1:length(names.r1.list)){
  for(j in 1:length(names.r1.list)){
    iset.primer = intersect(r1.list[[i]],
                            r2.list[[j]])
    primer.overlap[i,j] = length(iset.primer)
  }
}

primer.overlap.original = primer.overlap

### Check first

which(primer.overlap.original > 0, arr.ind = T)


primer.overlap = primer.overlap[which(rowSums(primer.overlap) > 0),] 
primer.overlap = primer.overlap[,which(colSums(primer.overlap) > 0)] 

primer.overlap.rows = rownames(primer.overlap)
primer.overlap.cols = colnames(primer.overlap)

primer.overlap.rows.c = which(primer.overlap.rows != "COV-N1-FOR-BC028")
primer.overlap.cols.c = which(primer.overlap.cols != "COV-N1-FOR-BC028")

primer.overlap.c = primer.overlap[primer.overlap.rows.c,
                                  primer.overlap.cols.c]

print(primer.overlap.c)

write.csv(primer.overlap.c,file=opt$output_file)


