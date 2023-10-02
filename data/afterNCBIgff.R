##NCBIからごり押しで各生物種のGFFをダウンロードし、以下のコマンドで解凍した
##unzip -d Desktop/project/LSI/GFF/Ac.gen.faa Downloads/Ac.gen.zip
##これにより、LSI/GFFに、興味ある生物種の解凍されたファイルがたくさんできた
library(tidyverse)

kyoumi = "data/GFF/falconparrots"
files <- list.files(kyoumi)
for (m in files) {
  bunkatu <- m %>% strsplit("\\.")
  namae <- paste(bunkatu[[1]][1], bunkatu[[1]][2], sep = ".")
  path <- paste(kyoumi, m, "ncbi_dataset/data", sep = "/")
  
  list_fi <- list.files(path)
  accession <- list_fi[str_detect(list_fi, "GC*._")]
  
  ren_from <- paste(path, accession, "genomic.gff", sep = "/")
  ren_to <- paste(kyoumi, "/", namae, "gff", sep = ".")
  file.rename(from = ren_from, to = ren_to)
}

##これで、GFFに欲しいgenomic.gffの名前を種名に変えたファイルが取れるはず
##gff2gene.Rへ