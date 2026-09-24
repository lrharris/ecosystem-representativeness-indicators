library(ggpattern)
library(tidyverse)

# PROTECTED EXTENT, REPRESENTIVITY & CONDITION-ADJUSTED REPRESENTIVITY ---------

#Calculate realm extent
realm_ext<-tibble(et_merge %>%
                        group_by(realm) %>%
                        summarize(realm_area = sum(et_area_sqkm))) %>%
  select(-geometry)

##Calculate Representivity Indicator
represR<-tibble(pa_et_yr %>% 
                  filter(pa_year=="2023") %>%
                  group_by(realm) %>%
                  summarize(rep_area = sum(cum_intersect_area_yr_t),
                            prot_area = sum(cum_intersect_area_yr))) %>% 
  mutate(rep_area=as.numeric(rep_area) %>% units::set_units(km^2), 
         realm=factor(as.character(realm)))

represRc<-tibble(pa_et_yr_c %>% 
                  filter(pa_year=="2023") %>%
                  group_by(realm) %>%
                  summarize(rep_c_area = sum(cum_intersect_c_area_yr_t))) %>% 
  mutate(rep_c_area=as.numeric(rep_c_area) %>% units::set_units(km^2), 
         realm=factor(as.character(realm)))


dC<-left_join(represR, represRc, by ="realm") %>% 
  left_join(., realm_ext,by ="realm") %>% 
  mutate(cond_repres_prop = as.numeric(rep_c_area/realm_area*100),
         repres_prop=as.numeric((rep_area-rep_c_area)/realm_area*100),
         additional_prop=as.numeric((prot_area-rep_area)/realm_area*100),
         realm=factor(as.character(realm)),
         realm = fct_relevel(realm, c("terrestrial", "wetland", "estuary", 
                                      "marine", "pelagic", "pei"))); dC

## Format the data for the graph -----------------------------------------------
dc1 <- pivot_longer(dC, cols=c("cond_repres_prop", "repres_prop", 
                               "additional_prop"), 
                    names_to = "protection_type", values_to = "prop") %>% 
  select(protection_type, realm, prop) %>% 
  mutate(protection_type=ordered(protection_type, levels=c("additional_prop",
                                                          "repres_prop",
                                                          "cond_repres_prop")),
         realm = ordered(realm, c("pei", "pelagic","marine", "estuary", 
                                  "wetland", "river", "terrestrial"))) %>% 
  arrange(protection_type, realm)

dc1$realm <- ordered(case_match(dc1$realm, "terrestrial" ~ "Terrestrial", 
                                "river" ~ "Rivers",
                           "wetland" ~ "Wetlands","estuary" ~ "Estuaries", 
                           "marine" ~ "Marine: benthic", 
                           "pelagic" ~ "Marine: pelagic", "pei"~ "PEI"), 
                     levels= c("PEI", "Marine: pelagic","Marine: benthic",
                               "Estuaries","Wetlands", "Rivers", "Terrestrial"))

dc1$protection_type <- ordered(case_match(
  dc1$protection_type, 
  "additional_prop" ~ "Additional protected area coverage",
  "repres_prop" ~ "Representativeness",
  "cond_repres_prop" ~ "Condition-adjusted representativeness"),
  levels=c("Additional protected area coverage","Representativeness",
           "Condition-adjusted representativeness"))


## Prepare the plot ------------------------------------------------------------
EPL.C<-ggplot(dc1, aes(x = realm, y = prop, pattern_angle=protection_type))+
  geom_col_pattern(aes(fill = protection_type), width = 0.7, 
                   pattern_fill=STRIPES, pattern_color=STRIPES, 
                   pattern_spacing=0.02, pattern_size = 0.1, 
                   pattern_density=0.45,
                   pattern="stripe")+
  geom_hline(yintercept = 30, lty="dashed")+
  coord_flip()+
  scale_fill_manual(values = EPL.condition)+
  scale_pattern_angle_manual(values = c(90,90,90))  +
  xlab("")+
  ylab("Percent of Realm Extent")+
  scale_y_continuous(labels = scales::percent_format(scale = 1))+
  theme(legend.title = element_blank())+
  theme(legend.key.size = unit(0.6, 'cm'))+
  theme(legend.position = c(0.99, 1.01), 
        legend.justification = c("right", "top"))+
  guides(pattern = guide_legend(override.aes = list(fill = "white"), order = 2),
         fill = guide_legend(override.aes = list(pattern = "none", order = 1)))



# PLOT RESULTS -----------------------------------------------------------------
EPL.C

