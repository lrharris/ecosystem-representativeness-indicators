library(ggpubr)
library(tidyverse)

# READ THE FUNCTIONS AND PALETTES ----------------------------------------------
source("Code/B1_realm_get-started_plot-themes-palettes-functions.R")

epl_get_data <- read_csv("data/epl_get.csv")
efg_cn <- read_csv("data/efg_codenames.csv")

epl_get <- epl_get_data %>% 
  group_by(efg_code) %>% 
  count(EPL)

epl_get$EPL <- ordered(epl_get$EPL, levels=c("Not Protected", 
                                             "Poorly Protected", 
                                             "Moderately Protected", 
                                             "Well Protected"))

epl_get <- epl_get %>% 
  left_join(efg_cn, by=join_by(efg_code), keep=F)%>% 
  rename(cat=efg_codename) %>% 
  rename(epl=EPL) %>% 
  mutate(efg_code=factor(as.character(efg_code)),
         efg_code = fct_relevel(efg_code, rev(c("T1.2","T2.4","T3.1","T3.2","T4.1",
                                            "T4.2","T4.5","T5.1", "T5.2","T5.5",
                                            "T6.1","T6.2","T6.3", 
                                            "MT1.1","MT1.3","MT1.4","MT2.1", 
                                            "FM1.2","FM1.3","M1.2",
                                            "M1.3","M1.5","M1.6","M1.7","M1.8",
                                           "M3.1","M3.2","M3.3","M3.4",
                                            "M3.5")))) %>% 
  arrange(efg_code, epl)
  
factlev <- unique(epl_get$cat)

epl_get <- epl_get %>% 
mutate(cat = ordered(cat, factlev))


  # mutate(efg_codename = ordered(efg_codename, cn)) %>% 
  # arrange(protection_type, efg_codename)


epl_tg <- epl_graph(epl_data=epl_get, metric="Types")+
  theme(axis.text.y = element_text(size = 12)); epl_tg
