##RedListからsummary tableをダウンロードし、非都市鳥だけをとる
library(tidyverse)

##都市鳥のデータをダウンロード。非都市鳥のデータからこれらの種を排除
UB <- read_csv("distinguish/Urbanbirds.csv") %>% 
  select(c("scientificName", "orderName", "familyName")) %>%
  mutate(habits = "U")
NUB <- read_csv("distinguish/NonUrbanbirds.csv") %>% 
  select(c("scientificName", "orderName", "familyName")) %>%
  mutate(habits = "NU")


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

UB2 <- UB %>%
  left_join(Freshwater, by = "scientificName") %>% 
  left_join(Marine, by = "scientificName")

##UBirdsは、NonUrbanでもありUrbanでもあるやつ。これはUrban birdsとして定義する
UBirds <- NUB2$scientificName[NUB2$scientificName %in% UB2$scientificName]
NUB3 <- NUB2 %>% filter(!NUB2$scientificName %in% UBirds)
##NUB3はUrbanで確認されてない鳥類
WholeBirds <- bind_rows(NUB3, UB2)
WholeBirds %>% write_csv("samplelist/WholeBirds.csv")

##ggplot
grDevices::palette("Okabe-Ito")
options(
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis",
  ggplot2.discrete.colour = grDevices::palette()[-1],
  ggplot2.discrete.fill = grDevices::palette()[-1]
)

WholeBirds2 <- WholeBirds %>% 
  mutate(orderName = fct_infreq(orderName)) %>%
  group_by(orderName)
WholeBirds3 <- WholeBirds2 %>% count(orderName, habits)
WholeBirds4 <- WholeBirds3 %>% 
  pivot_wider(names_from = habits, values_from = n) %>%
  mutate(prop = U/NU) %>%
  mutate(prop = factor(prop, ordered = TRUE)) %>%
  mutate(orderName = fct_lump(orderName, n = 5))

ggplot(WholeBirds4) +
  aes(x = U, y = NU, color = orderName) +
  geom_point() +
  theme_classic()

