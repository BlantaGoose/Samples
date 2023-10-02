##興味のある条件でRedListから取り出したcsvファイルを読み込む
##また、NCBIから取り出した鳥類のaccession情報が乗ったtsvファイルも用意
library(tidyverse)

##WholeBirds.csvはIUCNからとってきた現生鳥類
WholeBirds <- read_csv("samplelist/WholeBirds.csv")

##accession.tsvはNCBIのゲノムブラウザから全アノテーション済み、リファレンスのゲノムをとってきたtsv
accession <- read_tsv("samplelist/accession.tsv")
#そもそも遺伝情報がストックされた鳥類は何種なのか
Bosuu <- accession %>% distinct(`Organism Name`)
#364種

#では、興味のあるTaxonomyでしかもアクセッションがついている種（すなわち、ダウンロードする種）は?
df <- left_join(WholeBirds, accession, by = c(scientificName = "Organism Name"))
df2 <- df %>% 
  relocate(scientificName, `Assembly Accession`)
dfGenbank <- df2 %>% 
  filter(!is.na(`Assembly Accession`)) %>%
  filter(str_detect(`Assembly Accession`, "GCA")) %>% 
  select(scientificName, `Assembly Accession`)

dfRefseq <- df2 %>% 
  filter(!is.na(`Assembly Accession`)) %>%
  filter(str_detect(`Assembly Accession`, "GCF"))

##Telluravesに含まれる種だけをとってこよう
telluraves_clade <- c("ACCIPITRIFORMES", "CATHARTIFORMES", "STRIGIFORMES", "COLIIFORMES", "LEPTOSOMIFORMES", "TROGONIFORMES", "BUCEROTIFORMES", "CORACIIFORMES", "PICIFORMES", "CARIAMIFORMES", "FALCONIFORMES", "PSITTACIFORMES", "PASSERIFORMES")
dfRefseq_telluraves <- dfRefseq %>%
  filter(orderName %in% telluraves_clade)

write.table(dfRefseq_telluraves,
            file = "./samplelist/telluraves/telluraves_sample.csv",
            sep = ",",
            row.names = FALSE,
            col.names = FALSE)
##Splicing Isoformを抽出する必要があるので、基本はRefSeqでよい
##col.namesオプションはFALSEの方がいい（scraping.shするとき、面倒になるので）

##無事、Accession.tsvとWholeBirds.csvを結合できたので、scraping.shでとってこよう
#あと、ReferenceかつAnnotationされてるやつを選ばないと、
#遺伝子領域が書いていないfnaを抽出することになる.



##
##8/7　なんだか、Passeriformesでは、NCBIから取得できていない種がまだいるみたい。マニュアルでやるしかないかな
df_passeriformes <- read_csv(file = "samplelist/telluraves/telluraves_sample.csv", col_names = FALSE) %>%
  filter(X3 == "PASSERIFORMES")

##NCBIのGenome browserからダウンロードしたTableの読み込み。マニュアルで撮る必要があるやつ
passeriformes_ncbi <- read_tsv("samplelist/telluraves/passeriformes_ncbi.tsv") %>%
  filter(str_detect(`Assembly Accession`, "^GCF"))
passeriformes_ncbi[[3]]
afroaves_ncbi <- accession %>%
  filter(`Organism Name` == "Aquila chrysaetos chrysaetos" | `Organism Name` == "Buceros rhinoceros silvestris") %>%
  filter(str_detect(`Assembly Accession`, "^GCF"))
wanna_add <- bind_rows(passeriformes_ncbi, afroaves_ncbi)


##passeriformes_ncbi[3]から取得できていないpasseriformesの種を検索
additional_passeriformes <- setdiff(wanna_add[[3]], df_passeriformes[[1]])
add_pas <- additional_passeriformes %>% as.data.frame()
add_pas_df <- add_pas %>% left_join(accession, by = c(`.` = "Organism Name")) %>%
  filter(str_detect(`Assembly Accession`, "^GCF")) %>% 
  dplyr::rename(OrganismName = ".") %>% 
  left_join(WholeBirds, by = c(OrganismName = "scientificName"))

##add_pas_dfもExcelに保存しておこう。
##こいつらが最初のscrapingでとれてこなかったのは、scraping.shの前に行なったこのスクリプトに問題があったかも
##というのも、IUCNからとってきたWholeBirdsのデータの中に、こいつらのデータが存在しない。
add_pas_df %>% write.table(file = "samplelist/telluraves/add_sample.csv",
                         sep = ",",
                         row.names = FALSE,
                         col.names = FALSE)
