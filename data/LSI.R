##gff2geneとLength.Rが終わったら
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
##Birds <- list.files("data/FAA", pattern = ".faa")


for (i in Birds) {
  namae <- str_split(i, ".faa")[[1]][1]
  
  ##タンパク配列の長さを読んだ、nagasa.csvを読み込み
  nagasa <- read_csv(paste("data/GFF/", path, "/", namae, ".nagasa.csv", sep = ""))
#  nagasa <- read_csv(paste("data/GFF/", namae, ".nagasa.csv", sep = ""))
  ##GeneIDとProteinIDを紐付けする。gffのCDSに保存されているので、これを呼び出す
  geneid <- read_csv(paste("data/GFF/", path, "/", namae, ".CDS.gff", sep = ""))
  ##geneidの処理
  ott <- geneid %>% left_join(nagasa, by = c("proid" = "proteinID"))
  ottt <- ott %>% 
    group_by(genid) %>%
    summarize(maxLen = max(seqLen))
  otttt <- ottt %>% 
    left_join(ott, by = c(genid = "genid", maxLen = "seqLen")) %>% 
    distinct(genid, .keep_all = TRUE) %>%
    na.omit()
  
  ##otttt完成
  n = 1
  while (n <= nrow(otttt)) {
    write.fasta(otttt$Gensequence[n],
                otttt$genid[n],
                file.out = paste("data/LSI/raw/", path, "/", namae, ".LSI.faa", sep = ""),
                open = "a")
    n <- n + 1
  }
  n = 0
}

#Check the number
list.files(paste("data/LSI/raw", path, sep = "/"), pattern = ".LSI.faa")
