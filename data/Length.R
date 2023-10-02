##gene2protein.Rによって、興味ある生物種のgeneIDproteinIDの対応をとった。
##次は、各proteinIDの配列の長さを計算する
library(tidyverse)
library(ape)
library(Biostrings)
library(seqinr)

##Creating file lists which need to curate in.
##Please enter your file name containing raw data in kyoumi object.
path = "add2"
kyoumi_faa <- paste("data/FAA", path, sep = "/")
kyoumi_fna <- paste("data/FNA", path, sep = "/")
Birds <- list.files(kyoumi_faa, pattern = ".faa")

##Birds <- list.files(paste("data/FAA/", path, sep = ""), pattern = )
##curating each of files in list
##species name is used of variable number
for (i in Birds) {
  namae <- str_split(i, ".faa")[[1]][1]
  
  ##FASTAファイルを一行目...名前、二行目...配列のdfにしてみよう
  ##read FASTA file
  ###readAAStringSet is bring width(sequence length), seq, names
  Genfasta_total <- readAAStringSet(paste(kyoumi_faa, i, sep = "/"))
#  Genfasta_total = readAAStringSet(paste("data/FAA/", i, sep = ""))
  
  ##Extracting names and seq from FASTA
  Genseq_name = names(Genfasta_total)
  Gensequence = paste(Genfasta_total)
  
  ##creating data.frame
  Gendf <- data.frame(Genseq_name, Gensequence)
  
  ##df[seq_name] contains first rows in FASTA file, so removing protein name
  Gendf2 = Gendf %>% 
    separate(Genseq_name, 
             into = c("proteinID", NA), 
             sep =" ") %>% 
    mutate(seqLen = str_length(Gensequence))
  ##これで、proteinIDとその配列を取り出した
  ##次は、遺伝子IDとproteinIDを紐付けする
  
  write_csv(Gendf2, paste("data/GFF/", path, "/", namae, ".nagasa.csv", sep = ""))
#  write_csv(Gendf2, paste("data/GFF/", namae, ".nagasa.csv", sep = ""))
}

##全部作成できたかな
list.files(paste("data/GFF", path, sep = "/"), pattern = ".nagasa.csv")

##いよいよ、geneIDごとにproteinIDをまとめて最大長だけを取り出す
##LSIprotein.Rで、LSIなproteinのfastaにしよう