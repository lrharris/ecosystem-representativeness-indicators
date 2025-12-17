library(tidyverse)

data_d<-tibble(pa_et_yr %>% 
                  filter(pa_year=="2023"))%>%
  select(realm,
         eco_type, 
         total_et_area, 
         cum_intersect_area_yr, 
         cum_intersect_area_yr_t)

data_d_c<-tibble(pa_et_yr_c %>% 
                   filter(pa_year=="2023"))%>%
  select(eco_type, cum_intersect_c_area_yr_t)

data_d <- data_d %>% 
  left_join(data_d_c, by = "eco_type")

data_d$cum_intersect_c_area_yr_t[is.na(data_d$cum_intersect_c_area_yr_t)] <- 0

data_d <- data_d %>% 
  mutate(
    additional_prop = as.numeric((
      cum_intersect_area_yr-cum_intersect_area_yr_t)/total_et_area*100),
    repres_prop = as.numeric((
      cum_intersect_area_yr_t-cum_intersect_c_area_yr_t)/total_et_area*100),
    cond_repres_prop= 
      as.numeric(cum_intersect_c_area_yr_t/total_et_area*100),
    cond_repres_prop_sort=cond_repres_prop,
    total_prop = additional_prop + repres_prop + cond_repres_prop,
    repres_prop_sort=repres_prop)


data_d <- data_d %>% 
  mutate(EPL=ifelse(cond_repres_prop>=30, "WP", 
                    ifelse(cond_repres_prop>=15, "MP",
                           ifelse(cond_repres_prop<1.5, "NP", "PP"))),
         EPL=factor(EPL, levels=c("NP", "PP", "MP", "WP")))


data_d1 <- pivot_longer(data_d, cols=c("cond_repres_prop", 
                                       "repres_prop",
                                       "additional_prop"),
                        names_to = "protection_type",
                        values_to = "prop") %>% 
  select(realm,
         eco_type, 
         EPL, 
         cond_repres_prop_sort, 
         repres_prop_sort, 
         total_prop, 
         protection_type, 
         prop) %>% 
  mutate(protection_type=ordered(protection_type, levels=c("additional_prop",
                                                           "repres_prop",
                                                           "cond_repres_prop")),
         realm = ordered(realm, c("pei", "pelagic","marine", "estuary", 
                                  "wetland", "river", "terrestrial"))) %>% 
  arrange(protection_type, realm)

# data_d1$realm <- ordered(case_match(data_d1$realm, "terrestrial" ~ "Terrestrial", 
#                                 "wetland" ~ "Wetlands","estuary" ~ "Estuaries", 
#                                 "marine" ~ "Marine: benthic", 
#                                 "pelagic" ~ "Marine: pelagic", "pei"~ "PEI"), 
#                      levels= c("PEI", "Marine: pelagic","Marine: benthic",
#                                "Estuaries","Wetlands", "Terrestrial"))

data_d1$protection_type <- ordered(case_match(
  data_d1$protection_type, 
  "additional_prop" ~ "Additional Protected Area Coverage", 
  "repres_prop" ~ "Representativeness",
  "cond_repres_prop" ~ "Condition-Adjusted Representativeness"),
  levels=c("Additional Protected Area Coverage","Representativeness",
           "Condition-Adjusted Representativeness"))

epl_dat_e <- data_d1 %>% 
  filter(realm == "estuary") %>% 
  arrange(cond_repres_prop_sort, total_prop) %>% 
  mutate(sort=(cond_repres_prop_sort*150)+(repres_prop_sort*130)+total_prop,
    eco_type = fct_reorder(eco_type, sort))

STRIPES2=c(rep(c("transparent","transparent", "#41b6c4"),nrow(epl_dat_e)/3))

EPL_estuaries<-ggplot(epl_dat_e, aes(x = eco_type, y = prop, pattern_angle=protection_type))+
  #geom_col(aes(fill = protection_type), width = 0.7)+
  geom_col_pattern(aes(fill = protection_type), pattern="stripe", width = 0.7, 
                   pattern_fill=STRIPES2, pattern_color=STRIPES2, 
                   pattern_spacing=0.015, pattern_size = 0.1, 
                   pattern_density=0.45)+
  geom_hline(yintercept = 30, lty="dashed")+
  coord_flip()+
  scale_fill_manual(values = EPL.condition)+
  scale_pattern_angle_manual(values = c(90,90,90))  +
  xlab("")+
  ylab("Percent of Ecosystem Extent")+
  scale_y_continuous(labels = scales::percent_format(scale = 1))+
  #theme(legend.position="bottom")+ #'none' to suppress
  theme(legend.title = element_blank())+
  theme(legend.key.size = unit(0.6, 'cm'))+
  theme(legend.position = c(0.535, 0.07))+
  guides(pattern = guide_legend(override.aes = list(fill = "white"), order = 2),
         fill = guide_legend(override.aes = list(pattern = "none", order = 1)))+
  annotate("rect", xmin = 17.6, xmax = 24.4, ymin = 100, ymax = 105,
           fill= "#4B6D02")+
  annotate("rect", xmin = 13.6, xmax = 17.4, ymin = 100, ymax = 105,
           fill= "#84AB5C")+
  annotate("rect", xmin = 8.6, xmax = 13.4, ymin = 100, ymax = 105,
           fill= "#84AB5C")+
  annotate("rect", xmin = 1.6, xmax = 8.4, ymin = 100, ymax = 105,
           fill= "#D5DDC5")+
  annotate("rect", xmin = 0.6, xmax = 1.4, ymin = 100, ymax = 105,
           fill= "#A6A6A6")+
  annotate("text", x=21, y=102.5, label= "WP", cex=3, col="white")+
  annotate("text", x=15.5, y=102.5, label= "MP*", cex=3, col="white")+
  annotate("text", x=11, y=102.5, label= "MP", cex=3, col="white")+
  annotate("text", x=5, y=102.5, label= "PP", cex=3)+
  annotate("text", x=1, y=102.5, label= "NP", cex=3, col="white")


# PLOT RESULTS -----------------------------------------------------------------
## Figure 6

pdf(here("outputs", "Figure6.pdf"),width=10,height=7)
EPL_estuaries
dev.off()

#9.21 x 5
