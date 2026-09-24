library(ggpubr)
library(tidyverse)

# READ THE FUNCTIONS AND PALETTES ----------------------------------------------
#source(here("code/B1_realm_get-started_plot-themes-palettes-functions.R"))

# COMPILE THE DATA -------------------------------------------------------------
# needs the object *pa_et_yr* that was compiled in:
# source(here("code", "A3_national_analysis_representivity.R"))

epli_rawdata<-pa_et_yr %>%
  mutate(prop_of_target = as.numeric(cum_intersect_area_yr_t/target_et_area))%>%
  mutate(epli_et = ifelse(prop_of_target>=1, 3, 
                          ifelse(prop_of_target>=0.5, 2, 
                                 ifelse(prop_of_target<0.05, 0, 1)))) %>% 
  mutate(epli_max = 3)

epli_dat<-epli_rawdata %>% 
  rename(grp = realm, year = pa_year) 
epli_dat$grp <- case_match(epli_dat$grp, "terrestrial" ~ "Terrestrial", 
                           "river" ~ "Rivers",
                           "wetland" ~ "Wetlands",
                           "estuary" ~ "Estuaries", 
                           "marine" ~ "Marine: benthic", 
                           "pelagic" ~ "Marine: pelagic",
                           "pei"~ "PEI")
epli_dat<-epli_dat %>%
  group_by(grp, year) %>%
  summarize(epli_sumscore = sum(epli_et), epli = epli_sumscore/sum(epli_max)) %>%   mutate(year = as.numeric(as.character(year))) %>% 
  mutate(grp = factor(grp, levels = c("Terrestrial","Rivers", "Wetlands","Estuaries", 
                                      "Marine: benthic", "Marine: pelagic", 
                                      "PEI")))

# PLOT -------------------------------------------------------------------------
EPLI<-epli_graph(epli_data=epli_dat); EPLI
         