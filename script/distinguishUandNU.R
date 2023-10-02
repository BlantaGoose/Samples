##RedListからsummary tableをダウンロードし、非都市鳥だけをとる
library(tidyverse)

##都市鳥のデータをダウンロード。非都市鳥のデータからこれらの種を排除
UB_proto <- read_csv("distinguish/Urbanbirds.csv")
UB <- UB_proto %>% 
  select(c("scientificName")) %>% 
  mutate(num = 1)
NUB <- read_csv("distinguish/NonUrbanbirds.csv") %>% 
  select(c("scientificName", "orderName", "familyName"))


##水生鳥類のデータも省く
Freshwater <- read_csv("distinguish/eliminated/Freshwatertaxonomy.csv") %>% 
  select(c(scientificName, familyName)) %>%
  rename(FreshwaterFamily = "familyName")
Marine <- read_csv("distinguish/eliminated/Marinetaxonomy.csv") %>% 
  select(c(scientificName, familyName)) %>%
  rename(MarineFamily = "familyName")

NUB2 <- NUB %>% 
  left_join(Freshwater, by = "scientificName") %>% 
  left_join(Marine, by = "scientificName")

UB2 <- UB %>% select(!c("num")) %>%
  left_join(Freshwater, by = "scientificName") %>% 
  left_join(Marine, by = "scientificName")

##FreshwaterでNA、MarineでNAのやつを取り出し、共通するやつのみ結合
##NUB2_Fは、FreshWaterでNameがあるやつは存在しないが、Marineで名前があるやつは存在する
NUB2_F <- NUB2[is.na(NUB2[4]),] %>% select(c("scientificName", "orderName", "familyName"))
NUB2_M <- NUB2[is.na(NUB2[5]),] %>% select(scientificName)
##NUB3は陸生鳥類
NUB3 <- inner_join(NUB2_F, NUB2_M, by = "scientificName")

##同様にUBにも
UB2_F <- UB2[is.na(UB2[2]),] %>% select(scientificName)
UB2_M <- UB2[is.na(UB2[3]),] %>% select(scientificName)
##UB3は陸生鳥類
UB3 <- inner_join(UB2_F, UB2_M, by = "scientificName") %>% 
  mutate(num = 1)

##NUB4が非都市鳥、UB4が都市鳥
NUB4 <- NUB3 %>% 
  left_join(UB3) %>% 
  filter(is.na(num)) %>% 
  select(!c("num"))

UB4 <- UB3 %>% 
  left_join(UB_proto) %>%
  select(c("scientificName", "orderName", "familyName"))

##write_csv()で保存
NUB4 %>% write_csv("distinguish/NU_redlist.csv")
UB4 %>% write_csv("distinguish/U_redlist.csv")


######おまけ
##NUB4やUB4を使用して、非都市鳥及び都市鳥それぞれにどんな鳥がいるか調べよう
NUcor <- NUB4 %>% filter(familyName == "CORVIDAE")
Ucor <- UB4 %>% filter(familyName == "CORVIDAE")



##水生鳥類の中に都市鳥はどのくらいいる？
##altaはそれぞれNUB及びUBリストの中にどれだけ水生鳥類がいるのか

Freshwater <- read_csv("distinguish/eliminated/Freshwatertaxonomy.csv") %>%
  select(c("scientificName", "orderName", "familyName"))
Marine <- read_csv("distinguish/eliminated/Marinetaxonomy.csv") %>%
  select(c("scientificName", "orderName", "familyName"))
NUB_alta <- NUB %>% mutate(habitats = "NonUrban")
jokyo <- UB %>% left_join(NUB) %>% select(c("scientificName", "num"))
jokyo

##NUBからUBを取り除く
WB_alta <- NUB %>% 
  left_join(jokyo, by = "scientificName") %>% select(c("scientificName", "num"))


FreshWB <- Freshwater %>% left_join(WB_alta, by = c("scientificName"))
MarineWB <- Marine %>% left_join(WB_alta, by = c("scientificName"))
Aquabirds <- FreshWB %>% bind_rows(MarineWB) %>% 
  distinct(scientificName, .keep_all = TRUE)
Groupaqua <- Aquabirds %>% 
  group_by(orderName) %>%
  count(num) %>%
  mutate(habitats = "num")