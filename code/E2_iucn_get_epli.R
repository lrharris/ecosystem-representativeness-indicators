library(ggrepel)

# COMPILE THE DATA -------------------------------------------------------------
## Read in the GET crosswalk master table
et_get <- read_csv(here("data", "Master_IEM_2018b_noFW_GET_RLE__20240725.csv"),
                        show_col_types = FALSE) %>% 
  select(iem_type, getbiome_code, efg_code) %>% 
  rename(eco_type = iem_type)

## 
epli_rawdata<-pa_et_yr %>%
  mutate(prop_of_target = as.numeric(cum_intersect_area_yr_t/target_et_area))%>%
  mutate(epli_et = ifelse(prop_of_target>=1, 3, 
                          ifelse(prop_of_target>=0.5, 2, 
                                 ifelse(prop_of_target<0.05, 0, 1)))) %>% 
  mutate(epli_max = 3)


epli_rawdata_get <- epli_rawdata %>% 
  inner_join(et_get, by=join_by(eco_type))


epli_dat_get<-epli_rawdata_get %>% 
  rename(year = pa_year) 

epli_dat_get<-epli_dat_get%>%
  group_by(getbiome_code, year) %>%
  summarize(epli_sumscore = sum(epli_et), epli = epli_sumscore/sum(epli_max)) %>%
  mutate(year = as.numeric(as.character(year))) %>% 
  mutate(grp = factor(getbiome_code, levels = c("T1","T2","T3","T4","T5","T6",
                                                "TF1","MT1","MT2","FM1", "MFT1",
                                                "M1","M2", "M3")))

# PLOT EPLI BY GET 2 -----------------------------------------------------------
EPLI_get<-epli_g_graph(epli_g_data=epli_dat_get)+
  theme(legend.position="right",
        axis.text.y = element_text(size = 9)); EPLI_get

# EPLI_get+
#   theme(legend.position = "none")+
#   annotate("text", x = 2023.2, y = ann1$epli, label = ann1$getbiome_code,
#            hjust = 0)+
#   scale_x_continuous(breaks = seq(2000,2025, by = 4), limits=c(2000,2025.5))

# Export pdf 9.21 x 6.29


# SUMMARISE EPLI AT GET 2 BY COUNTRY -------------------------------------------
epli_avetrend <- epli_dat_get %>%
  group_by(year) %>%
  summarise(mean_epli = mean(epli),
            sd_epli = sd(epli))

ave_EPLI_graph <- ggplot(data = epli_avetrend, aes(x = year)) + 
  geom_line(aes(y = mean_epli), linewidth = 1) + 
  geom_ribbon(aes(y = sd_epli, ymin = mean_epli - sd_epli, ymax = mean_epli + sd_epli), alpha = .2) +
  scale_y_continuous(limits=c(0,1))+
  scale_x_continuous(breaks = seq(2000,2023, by = 4))+
  labs(x="Year", y="EPLI (mean \u00b1 SD)"); ave_EPLI_graph


# SUMMARISE EPLI AT GET 2 BY GET 1 ---------------------------------------------
getrealm <- read_csv(here("data", "get123_codes.csv"),
                     show_col_types = FALSE)

epli_avetrend_grp <- epli_dat_get %>%
  left_join(getrealm, by=join_by("getbiome_code")) %>% 
  group_by(get_realm, year) %>%
  summarise(mean_epli = mean(epli),
            sd_epli = sd(epli))

ave_EPLI_graph_GET1 <- ggplot(data = epli_avetrend_grp, aes(x = year, group=get_realm)) + 
  geom_line(aes(y = mean_epli, color=get_realm), linewidth = 1) + 
  scale_color_manual(values=c("darkblue", "forestgreen", "gold"))+
  geom_ribbon(aes(y = sd_epli, ymin = mean_epli - sd_epli, 
                  ymax = mean_epli + sd_epli, fill=get_realm), alpha = .1) +
  scale_fill_manual(values=c("darkblue", "forestgreen", "gold"))+
  scale_y_continuous(limits=c(0,1))+
  scale_x_continuous(breaks = seq(2000,2023, by = 4))+
  labs(x="Year", y="EPLI (mean \u00b1 SD)", col="", fill="")+
  theme(legend.position = c(1,0),
        legend.justification = c("right", "bottom")); ave_EPLI_graph_GET1


# PLOT OUTPUT ------------------------------------------------------------------
# ggarrange(ave_EPLI_graph,  ave_EPLI_graph, 
#           ave_EPLI_graph_GET1, ave_EPLI_graph_GET1, 
#           EPLI_get, EPLI_get,  
#           nrow = 3,ncol=2, common.legend = F)

# save as pdf 5 x 12 for 1 col, 10 x 12 for 2 col