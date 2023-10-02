##IUCNとNCBIのデータフレームを統合し、スクレイピングで参照するデータフレームを作成
library(tidyverse)

path = "otameshi"
##IUCNから興味ある生物種のcsvデータを取ってこよう
allbirds <- read_csv(paste("samplelist", path, "taxonomy.csv", sep = "/")) %>%
  distinct(scientificName, .keep_all = TRUE)
##NCBIからゲノム情報のある生物種のデータをダウンロードしよう
ncbi <- read_tsv(paste("samplelist", path, "ncbi_dataset.tsv", sep = "/"), col_names = TRUE) 
Bosuu <- ncbi %>% distinct(`Organism Name`, .keep_all = TRUE)

allbirdsgenome <- ncbi %>% 
  left_join(allbirds, by = c(`Organism Name` = "scientificName"))
allbirdsGenbank <- allbirdsgenome %>% 
  filter(str_detect(`Assembly Accession`, "GCA")) %>% 
  select(`Organism Name`, `Assembly Accession`)
allbirdsrefseq <- allbirdsgenome %>% 
  filter(str_detect(`Assembly Accession`, "GCF")) %>% 
  select(`Organism Name`, `Assembly Accession`)

write.table(allbirdsGenbank, 
            file = paste("samplelist", path, "allbirdsGenbank.csv", sep = "/"), 
            sep = ",", 
            row.names = FALSE,
            col.names = FALSE)    #headerを消した（列名として）

##ゲノムのある鳥類→都市鳥の順番
terrestrialUrban <- read_csv(paste("samplelist", path, "TerrestrialBirdsassessments.csv", sep = "/"))
genometerrestrial <- allbirdsgenome %>% left_join(terrestrialUrban, by = c(`Organism Name` = "scientificName")) %>%
  distinct(`Organism Name`, .keep_all = TRUE)

##都市鳥は？
FW <- read_csv("samplelist/eliminated/Freshwatertaxonomy.csv")
MR <- read_csv("samplelist/eliminated/Marinetaxonomy.csv")
AQ <- bind_rows(FW, MR) %>% distinct(scientificName, .keep_all = TRUE)
AQ2 <- AQ %>% inner_join(genometerrestrial, by = c(scientificName = "Organism Name")) %>% mutate(AQ = 1)
genometerrestrial2 <- genometerrestrial %>% left_join(AQ2, by = c(`Organism Name` = "scientificName")) %>% filter(is.na(AQ))
