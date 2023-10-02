##これはattributesから"geneID"を抽出しリストにするスクリプト
##gff2gene.Rによるファイル整形が終わった後
library(tidyverse)
library(ape)
library(Biostrings)
library(seqinr)

##Creating file lists which need to curate in.
##Please enter your file name containing raw data in kyoumi object.
kyoumi <- "data/GFF/"
BirdsGFF <- list.files(kyoumi, pattern = "CDS.gff")

##curating each of files in list
##species name is used of variable number
for (i in BirdsGFF) {
  gff_gene <- read_csv(paste(kyoumi, i, sep = "/"))
  ##selecting "Dbxref=GeneID:XXXX,..." and "protein_id=XXXX" from separated columns
  hanbetu <- gff_gene  ##本当なら、読んだやり方の違いに合わせて（group_by("source"）)、遺伝子IDを取ってくるやり方も帰る方がいい。
  
  ##sourceがGnomonの時
  GenG1 <- gff_gene %>%
    filter(source == "Gnomon") %>%
    separate(attributes,
             into = c(NA, "geneID"), 
             sep = "GeneID:") %>%
    separate(geneID, into = c("geneID", NA), sep = ",")
  GenG2 <- gff_gene %>%
    filter(source == "Gnomon") %>%
    separate(attributes, into = c(NA, "proteinID"),
             sep = "protein_id=") %>%
    select(c("proteinID"))
  GenG3 <- bind_cols(GenG1, GenG2)

  ##sourceがRefSeqの時  
  GenR1 <- gff_gene %>%
    filter(source == "RefSeq") %>%
    separate(attributes,
           into = c(NA, "proteinID"),
           sep = "Genbank:") %>%
    separate(proteinID, 
             into = c("proteinID", "geneID"),
             sep = ",GeneID:") %>%
    separate(geneID,
             into = c("geneID", NA),
             sep = ";")

  Gen <- bind_rows(GenG3, GenR1) %>%
    separate(proteinID,
             into = c("proteinID", NA),
             sep = ";")
  Ge <- Gen %>% filter(!proteinID %in% NA)
  ##proteinIDがGFFに入ってなかった遺伝子を計算
  kesson <- Gen %>% filter(proteinID %in% NA) %>%
    separate(geneID,
             into = c("geneID", NA),
             sep = ";") %>%
    distinct(geneID)

  namae = str_split(i ,".CDS.gff")[[1]][1]
  print("=======================")
  print(paste("The number of gene without protein in", namae, "is", nrow(kesson), sep = " "))
  write_csv(Ge, paste(kyoumi, "/", namae, ".g2p.gff", sep = ""))
}
#GeneIDとProteinIDの対応を取り出した
##いよいよ、一番長いものを取り出すやつ。Length.Rへ
