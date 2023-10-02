install.packages("devtools")
devtools::install_github("ahhurlbert/aviandietdb")
data("dietdb")

library(tidyverse)

dietdb2 <- dietdb %>% distinct(Location_Region)

##肉食種... 魚類以上のChordataを食べる種
Chordata <- dietdb %>% filter(Prey_Phylum == "Chordata")
Chordata %>% distinct(Prey_Class)

##Teleostei ... 真骨類（魚類）、Chondrichthyes ... 軟骨魚類、Chondrostei ... 軟質亜綱、Cephalaspidomorphi ... 頭甲類、Holostei ... 硬骨魚類、Thaliacea ... 尾索動物、Actinopterygii ... 条鰭類
Carnivore <- Chordata %>% filter(Prey_Class == "Aves" | Prey_Class == "Mammalia" | Prey_Class == "Amphibia" | Prey_Class == "Reptilia")
Carnivore %>% distinct(Family)
