##afterNCBIgff.Rによるファイルの下処理が終わったら
##この段階ではまだ、"属名.種小名.gff"しかない
##このファイルは、gffを読み込みgeneだけを取り出すスクリプト
library(tidyverse)

##Creating file lists which need to curate in.
##Please enter your file name containing raw data in kyoumi object.
kyoumi <- "data/GFF/add2"


BirdsGFF <- list.files(paste(kyoumi, sep = "/"), pattern = ".gff")

##curating each of files in list
##species name is used of variable number
for (i in BirdsGFF) {
  print(i)
  namae = str_split(i ,".gff")[[1]][1]
  ##namaeは属+種名
  ##read GFF file
  gff_total = read_tsv(paste(kyoumi, i, sep = "/"), comment = "#", 
                       col_names = c("seqid", "source", "type", "start", "end", "score","strand", "phase", "attributes"))
  
  ##extract gene (行数がNCBIの数と一致するはず)
  ##2回目のseparate関数では、proteinIDを取り出すために、"Genbank"文字列に注目しているが、結構大変。最後にproteinID=XP_XXXXXに注目したほうがいいのかも
  gff_CDS <- gff_total %>% 
    dplyr::select(source, type, attributes) %>%
    filter(type == "CDS") %>%
    separate(attributes, 
             into = c(NA, "genid"),
             sep = "Dbxref=GeneID:") %>%
    separate(genid,
             into = c("genid", "rest"),
             sep = ",GenBank:")
  
  ##GFFファイルのattributesに"GenBank"と"Genbank"と入ってるやつの2タイプがある。
  if (!is.na(gff_CDS[["rest"]][1])) {
    gff_CDS <- gff_CDS %>% 
      separate(rest, 
               into = c("proid", NA), 
               sep = ";")
  } else {
    gff_CDS <- gff_CDS %>% 
      separate(genid, 
               into = c("genid", "rest"),
               sep = ",Genbank:") %>%
      separate(rest,
               into = c("proid", NA),
               sep = ";")
  }
  
#  gff_gene <- gff_total %>% 
#    dplyr::select(source, type, attributes) %>%
#    filter(type == "gene")
  
  ##保存
  write_csv(gff_CDS, paste(kyoumi, "/", namae, ".CDS.gff", sep = ""))
#  write_csv(gff_gene, paste(kyoumi, "/", namae, ".gene.gff", sep = ""))
}

##Lenmgth.Rへ
##gff_CDSでproidとgenidを紐付けした。
#次は、各proid（genid）の配列の長さを計算したFAA（FNA）を参照し
#genidごとにまとめ、最大長を取り出せば良い

##得られたファイル
##一列目にSource、2列目にCDS、三列目にgeneid、4列目にproteinid

##補足（以上のパイプラインで取り出せなかったやつのために）
##localでGFFファイルをよく見て、改善しよう
##Ch.burの場合
gff_CDS <- gff_total %>% dplyr::select(source, type, attributes) %>%
  filter(type == "CDS")
gff_CDS2 <- gff_CDS %>% separate(attributes, into = c("a", "b"), sep = "protein_id=") %>%
  dplyr::select(c("b"))
gff_CDS3 <- gff_CDS %>% separate(attributes, into = c("c", "d"), sep = "_mrna;Dbxref=NCBI_GP:") %>% 
  separate(c, into = c(NA, "e"), sep = "CHUBUR_") %>%
  dplyr::select(c("e"))
gff_CDS4 <- bind_cols(gff_CDS2, gff_CDS3)

gff_CDS5 <- gff_CDS4 %>% mutate(protein = gsub(b, pattern = ";.*", replacement = "")) %>%
  mutate(gene = gsub(e, pattern = ";.*", replacement = "")) %>%
  select(c("gene", "protein"))
gff_CDS6 <- gff_CDS %>% bind_cols(gff_CDS5) %>% 
  select(c(!"attributes")) %>%
  dplyr::rename(genid = "gene") %>%
  dplyr::rename(proid = "protein")

write_csv(gff_CDS6, "data/GFF/Ch.bur.CDS.gff")
