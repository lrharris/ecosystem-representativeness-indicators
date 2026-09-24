library(ggpattern)
library(tidyverse)

# PROTECTED EXTENT, REPRESENTIVITY & CONDITION-ADJUSTED REPRESENTIVITY ---------
# Add the IUCN GET ecosystem functional group codes to the data

et_get <- read_csv(here("data", "Master_IEM_2018b_noFW_GET_RLE__20240725.csv"),
                   show_col_types = FALSE) %>% 
  select(iem_type, getbiome_code, efg_code) %>% 
  rename(eco_type = iem_type)

et_merge_get <- et_merge %>% 
  right_join(et_get, by=join_by(eco_type), keep=F) 

# Calculate ecosystem functional group (GET3) extent
get3_ext<-tibble(et_merge_get %>%
                   group_by(efg_code) %>%
                   summarize(get3_area = sum(et_area_sqkm))) %>%
  select(-geometry)

## Calculate Representivity Indicator
pa_et_yr_g <- pa_et_yr %>%
  right_join(et_get, by=join_by(eco_type), keep=F)

represR_g<-tibble(pa_et_yr_g %>% 
                    filter(pa_year=="2023") %>%
                    group_by(efg_code) %>%
                    summarize(rep_area = sum(cum_intersect_area_yr_t),
                              prot_area = sum(cum_intersect_area_yr))) %>% 
  mutate(rep_area=as.numeric(rep_area) %>% units::set_units(km^2), 
         efg_code=factor(as.character(efg_code)))


pa_et_yr_c_g <- pa_et_yr_c %>% 
  right_join(et_get, by=join_by(eco_type), keep=F)

represRc_g<-tibble(pa_et_yr_c_g %>% 
                     filter(pa_year=="2023") %>%
                     group_by(efg_code) %>%
                     summarize(rep_c_area = sum(cum_intersect_c_area_yr_t))) %>% 
  mutate(rep_c_area=as.numeric(rep_c_area) %>% units::set_units(km^2), 
         efg_code=factor(as.character(efg_code)))


dC_get<-left_join(represR_g, represRc_g, by ="efg_code") %>% 
  left_join(., get3_ext,by ="efg_code") %>% 
  mutate(cond_repres_prop_g = as.numeric(rep_c_area/get3_area*100),
         repres_prop_g=as.numeric((rep_area-rep_c_area)/get3_area*100),
         additional_prop_g=as.numeric((prot_area-rep_area)/get3_area*100),
         efg_code=factor(as.character(efg_code)),
         efg_code = fct_relevel(efg_code, c("T1.2","T2.4","T3.1","T3.2","T4.1",
                                            "T4.2","T4.5","T5.1", "T5.2","T5.5",
                                            "T6.1","T6.2","T6.3","TF1.1", 
                                            "MT1.1","MT1.3","MT1.4","MT2.1", 
                                            "MFT1.2","FM1.2","FM1.3","M1.2",
                                            "M1.3","M1.5","M1.6","M1.7","M1.8",
                                            "M2.1","M3.1","M3.2","M3.3","M3.4",
                                            "M3.5"))); dC_get


## Format the data for the graph -----------------------------------------------
efg_cn <- read_csv("data/efg_codenames.csv")
cn <- efg_cn$efg_codename

dc_get1 <- pivot_longer(dC_get, cols=c("cond_repres_prop_g", "repres_prop_g", 
                                       "additional_prop_g"), 
                        names_to = "protection_type", values_to = "prop") %>% 
  select(protection_type, efg_code, prop) %>% 
  mutate(protection_type=ordered(protection_type, 
                                 levels=c("additional_prop_g",
                                          "repres_prop_g",
                                          "cond_repres_prop_g"))) %>% 
  left_join(efg_cn, by=join_by(efg_code), keep=F)%>% 
  mutate(efg_codename = ordered(efg_codename, cn)) %>% 
  arrange(protection_type, efg_codename)

# efg_code = ordered(efg_code, c("T1.2","T2.4","T3.1","T3.2","T4.1",
#                                "T4.2","T4.5","T5.1", "T5.2","T5.5",
#                                "T6.1","T6.2","T6.3","TF1.1", 
#                                "MT1.1","MT1.3","MT1.4","MT2.1", 
#                                "MFT1.2","FM1.2","FM1.3","M1.2",
#                                "M1.3","M1.5","M1.6","M1.7","M1.8",
#                                "M2.1","M3.1","M3.2","M3.3","M3.4",
#                                "M3.5"))

dc_get1$protection_type <- ordered(case_match(
  dc_get1$protection_type, 
  "additional_prop_g" ~ "Additional protected area coverage", 
  "repres_prop_g" ~ "Representativeness",
  "cond_repres_prop_g" ~ "Condition-adjusted representativeness"),
  levels=c("Additional protected area coverage","Representativeness",
           "Condition-adjusted representativeness"))


## Prepare the plot ------------------------------------------------------------
efgs <- length(unique(dc_get1$efg_code))

STRIPESg=c(rep("transparent",efgs), rep("transparent",efgs), rep("#41b6c4",efgs))

EPL.CG<-ggplot(dc_get1, aes(x = efg_codename, y = prop, pattern_angle=protection_type))+
  geom_col_pattern(aes(fill = protection_type), width = 0.7, 
                   pattern_fill=STRIPESg, pattern_color=STRIPESg, 
                   pattern_spacing=0.01, pattern_size = 0.1, 
                   pattern_density=0.45,
                   pattern="stripe")+
  geom_hline(yintercept = 30, lty="dashed")+
  coord_flip()+
  scale_fill_manual(values = EPL.condition)+
  scale_pattern_angle_manual(values = c(90,90,90))  +
  xlab("")+
  ylab("Percent of Ecosystem Functional Group Extent")+
  scale_y_continuous(labels = scales::percent_format(scale = 1))+
  #theme(legend.position="bottom")+ #'none' to suppress
  theme(legend.title = element_blank())+
  theme(legend.key.size = unit(0.6, 'cm'))+
  theme(legend.position = c(0.7, 0.055))+
  guides(pattern = guide_legend(override.aes = list(fill = "white"), order = 2),
         fill = guide_legend(override.aes = list(pattern = "none", order = 1)))



# PLOT RESULTS -----------------------------------------------------------------
EPL.CG

# pdf(here("outputs", "FigureS4.pdf"),width=10,height=9)
# EPL.CG
# dev.off()
#Save as pdf 10 x 9