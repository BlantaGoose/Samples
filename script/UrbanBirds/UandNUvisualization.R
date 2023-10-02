##各order(family)にどのくらいの都市鳥がいるのか？
library(tidyverse)

NUB <- read_csv("distinguish/NU_redlist.csv") %>%
  mutate(habitat = "NU")
UB <- read_csv("distinguish/U_redlist.csv") %>% 
  mutate(habitat = "U")

WB_order <- bind_rows(NUB, UB) %>% 
  group_by(orderName) %>%
  count(habitat)
WB_order

WB_family <- bind_rows(NUB, UB) %>% 
  group_by(familyName) %>%
  count(habitat)
WB_family
##OrderやFamilyごとにまとめてみる

##割合の計算
WB_order2 <- WB_order %>%
  pivot_wider(names_from = habitat, values_from = n) %>%
  mutate(prop = U/NU)

mysample <- read_csv("samplelist/honban/Paleognate3_28.csv") %>%
  mutate(orderName = toupper(orderName)) %>%
  select(c("orderName", "habitats"))
mysample_2 <- mysample %>% 
  group_by(orderName) %>%
  count(habitats) %>%
  pivot_wider(names_from = habitats, values_from = n) %>%
  rename(NU_my = "NU") %>%
  rename(U_my = "U") %>%
  replace_na(list(U_my = 0, NU_my = 0)) %>%
  mutate(prop_my = U_my/NU_my)
  
WB_order3 <- WB_order2 %>% left_join(mysample_2) %>%
  select(c("orderName", "prop", "prop_my"))

grDevices::palette("Okabe-Ito")
options(
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis",
  ggplot2.discrete.colour = grDevices::palette()[-1],
  ggplot2.discrete.fill = grDevices::palette()[-1]
)

##可視化
p <- ggplot(WB_order, aes(x=habitat, y=n, fill=habitat))
p + geom_bar(stat = "identity") + 
  facet_wrap(vars(orderName)) +
  theme_classic()

##