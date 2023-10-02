library(tidyverse)

##

NonUrbantax <- read_csv("samplelist/Whole_Non-Urban_Birds/taxonomy.csv")
Urbantax <- read_csv("samplelist/1021/1021taxonomy.csv")

#Wholetax <- read_csv("samplelist/WholeBirdsTaxonomy.csv") %>%
#  select(c("scientificName", "orderName", "familyName", "genusName"))
accession <- read_tsv("samplelist/accession.tsv")
#そもそも遺伝情報がストックされた鳥類は何種なのか
Bosuu <- accession %>% distinct(`Organism Name`)
#364種

#では、興味のあるTaxonomyでしかもアクセッションがついている種（すなわち、ダウンロードする種）は?
Urbandf <- left_join(Urbantax, accession, by = c(scientificName = "Organism Name"))
Urbandf <- Urbandf %>% relocate(scientificName, `Assembly Accession`)
UrbanGenbank <- Urbandf %>% filter(!is.na(`Assembly Accession`)) %>%
  filter(str_detect(`Assembly Accession`, "GCA")) %>% 
  select(scientificName, `Assembly Accession`)

UrbanRefSeq <-  df %>% filter(!is.na(`Assembly Accession`)) %>%
  filter(str_detect(`Assembly Accession`, "GCF"))

##NonUrban
NonUrbandf <- left_join(NonUrbantax, accession, by = c(scientificName = "Organism Name"))
NonUrbandf <- NonUrbandf %>% relocate(scientificName, `Assembly Accession`)
NonUrbanGenbank <- NonUrbandf %>% filter(!is.na(`Assembly Accession`)) %>%
  filter(str_detect(`Assembly Accession`, "GCA")) %>% 
  select(scientificName, `Assembly Accession`)

##もし、非都市鳥を抽出するなら、UrbanGenBankにいないやつを取ってくる必要あり。
aaa <- NonUrbanGenbank %>% 
  select(scientificName) %>% 
  left_join(UrbanGenbank, by = "scientificName")

##aaaにaccessionが入っているということは、都市鳥なのでcomplete.cases()で取り除く
NonUrban <- aaa[!complete.cases(aaa),]

##都市鳥を取り除いたので（回り道だが）、accessionをつける
NonUrban <- NonUrban %>% 
  select(scientificName) %>% 
  left_join(NonUrbanGenbank, by = "scientificName") %>%
  distinct(scientificName, .keep_all = TRUE)

write.table(NonUrban, 
            file = "./samplelist/Whole_Non-Urban_Birds/NonUrbanGenBank.csv", 
            sep = ",", 
            row.names = FALSE,
            col.names = FALSE)    #headerを消した（列名として）
#あと、ReferenceかつAnnotationされてるやつを選ばないと、
#遺伝子領域が書いていないfnaを抽出することになる.


##scraping後。data/species.txtの種をxlsxに保存
##UsedSpecies2は、抽出できたNonUrbanBirds249種のBUSCO valuesを保存するシート
UsedSpecies <- read_csv("samplelist/Whole_Non-Urban_Birds/data/species.txt", col_names = FALSE)

atarasi = c()

for (i in 1:nrow(UsedSpecies)) {
  zoku = UsedSpecies[i,1] %>% substr(0,1)
  setsudan = UsedSpecies[[i,1]] %>% strsplit("_")
  syusyou = setsudan[[1]][2] %>% substr(0,3)
  namae = paste(zoku, syusyou, "faa", sep = ".")
  atarasi = c(atarasi, namae)
}
atarasi ##appendだと二重リストになる

UsedSpecies2 <- UsedSpecies %>% mutate(ryakusyou = atarasi) %>%
  rename(scientificName = "X1")
UsedSpecies2[2]

write_csv(UsedSpecies2, "samplelist/Whole_Non-Urban_Birds/WholeNonUrbanSamples.csv")

FinishedSpecies <- read_csv("samplelist/Whole_Non-Urban_Birds/data/249sukosi_busco.csv")

##samples/samplelist/Whole_Non-Urban_Birds/WholeNonUrbanSamples.csvは、
##スクレイピングで「遺伝情報が存在する」非都市鳥の種名と略称のdataframe。
##DDBJに送ったfaaファイルや、transportにおいてあるfaaファイルで足りないものを参照できる。

UsedSpecies3 <- UsedSpecies2 %>% left_join(FinishedSpecies, by = c(scientificName = "Scientific Name"))
UsedSpecies3[1] <- UsedSpecies3[[1]] %>%
  str_replace_all("_", " ") %>% 
  as.data.frame() %>% 
  rename(scientificName = ".")

UsedSpecies4 <- UsedSpecies3 %>%
  left_join(tax) %>% 
  relocate(familyName, scientificName, ryakusyou, C)

write_csv(UsedSpecies4, "./samplelist/Whole_Non-Urban_Birds/UsedSpecies4.csv")

##BUSCOを一通り終えて、まだ取れてないやつをかけるために抽出
BUSCOusedspecies4 <- read_csv("samplelist/Whole_Non-Urban_Birds/UsedSpecies4.csv")

#BUSCOしてないやつの数
yet <- BUSCOusedspecies4[!complete.cases(BUSCOusedspecies4[4]),] %>% 
  left_join(accession, by = c(scientificName = "Organism Name"))

##scrapingで行うとき、ディレクトリにこれを入れる必要がある。
yet <- yet %>% unite(access, `Assembly Accession`, `Assembly Name`, sep = "_")

scrapingyet <- yet %>% select(c(scientificName, access)) %>%
  distinct(scientificName, .keep_all = TRUE)

write_csv(scrapingyet, 
          "samplelist/Whole_Non-Urban_Birds/2ndscraping/scrapingyet.csv", 
          col_names = FALSE)
##このscrapingyet.csvを元に、まだやってないやつのscrapingを行う。

##取れなかったやつ確認
torenai <- scrapingyet[1]


nouvelle = c()
i = 1
for (i in 1:nrow(torenai)) {
  zoku = torenai[i,1] %>% substr(0,2)
  setsudan = torenai[[i,1]] %>% strsplit(" ")
  syusyou = setsudan[[1]][2] %>% substr(0,3)
  namae = paste(zoku, syusyou, "faa", sep = ".")
  nouvelle = c(nouvelle, namae)
}
nouvelle ##appendだと二重リストになる

torenai2 <- torenai %>% mutate(ryakusyou = nouvelle)

##Linuxで、research/transport/find *.faa > text.txt
text <- read_table("../transport/text.txt", col_names = FALSE)

torenai2 <- torenai2 %>% left_join(text, by = c(ryakusyou = "X1"))


hosii = torenai2[2] %>% as.data.frame()
kannryou = text %>% as.data.frame() %>% mutate("1" = kannryou)


hosii %>% left_join(kannryou, by = c(ryakusyou = "X1"))

hosii[!complete.cases(hosii),]


##scrapingよう
scraping <- read_csv("buscovisuallize/WholeNonUrban/Wholesample.csv")
scraping <- scraping %>% left_join(accession, by = c(scientificName = "Organism Name"))
scraping <- scraping %>% separate(scientificName, into = c("genus", "species"), sep = " ") %>%
  unite(access, `Assembly Accession`, `Assembly Name`, sep = "_") %>% 
  unite(scientificName, genus, species, sep = "_") %>%
  select(c(scientificName, access))
scraping %>% distinct(scientificName)


write_csv(scraping, "samplelist/honban/scrapingHonban.csv", col_names = FALSE)
