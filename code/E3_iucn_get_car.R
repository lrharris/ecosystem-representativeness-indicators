library(units)

# Prepare the data -------------------------------------------------------------
## Join the GET levels to the ecosystem condition data -------------------------
car_get_rawdata <- pa_et_yr_c %>% 
  inner_join(et_get, by=join_by("eco_type"))

## Calcuate biome area ---------------------------------------------------------
biome_area <- car_get_rawdata %>%
  filter(pa_year==2023)%>% 
  group_by(getbiome_code) %>%
  summarize(biomearea = sum(total_et_area))

## Recalculate CAR by GET Biome (Level 2)
ca_repres_get<-car_get_rawdata %>% 
  group_by(getbiome_code, pa_year) %>%
  summarize(cum_rep_c_area = sum(cum_intersect_c_area_yr_t)) %>% 
  mutate(year=as.numeric(as.character(pa_year)))%>%
  left_join(repres[,c(1,4)], by = join_by(pa_year)) %>%
  left_join(pa_per_year, by = join_by(pa_year)) %>%
  left_join(biome_area, by = join_by(getbiome_code)) %>%
  mutate(conversionfactor = as.numeric(cum_pa_area/cum_rep_add_area),
         ca_representivity=as.numeric(cum_rep_c_area/biomearea*100))%>%
  mutate(grp = factor(getbiome_code, levels = c("T1","T2","T3","T4","T5","T6",
                                                "TF1","MT1","MT2","FM1", "MFT1",
                                                "M1","M2", "M3")))

# --------------------
ca_repres_get$grp <- ordered(case_match(
  ca_repres_get$grp, 
"T1" ~ "T1: Tropical-subtropical forests biome",
"T2" ~ "T2: Temperate-boreal forests and woodlands biome",
"T3" ~ "T3: Shrublands and shrubby woodlands biome",
"T4" ~ "T4: Savannas and grasslands biome",
"T5" ~ "T5: Deserts and semi-deserts biome",
"T6" ~ "T6: Polar/alpine (cryogenic) biome",
"TF1" ~ "TF1: Palustrine wetlands biome",
"MT1" ~ "MT1: Shorelines biome",
"MT2" ~ "MT2: Supralittoral coastal biome",
"FM1" ~ "FM1: Semi-confined transitional waters biome",
"MFT1" ~ "MFT1: Brackish tidal biome",
"M1" ~ "M1: Marine shelf biome",
"M2" ~ "M2: Pelagic ocean waters biome",
"M3" ~ "M3: Deep sea floors biome"),
levels=c(
  "T1: Tropical-subtropical forests biome",
  "T2: Temperate-boreal forests and woodlands biome",
  "T3: Shrublands and shrubby woodlands biome",
  "T4: Savannas and grasslands biome",
  "T5: Deserts and semi-deserts biome",
  "T6: Polar/alpine (cryogenic) biome",
  "TF1: Palustrine wetlands biome",
  "MT1: Shorelines biome",
  "MT2: Supralittoral coastal biome",
  "FM1: Semi-confined transitional waters biome",
  "MFT1: Brackish tidal biome",
  "M1: Marine shelf biome",
  "M2: Pelagic ocean waters biome",
  "M3: Deep sea floors biome"))
# -----------------------------------

car_get_plot <- ggplot(ca_repres_get, aes(x=year, y=ca_representivity, group=grp))+
  geom_line(linewidth=1.1, aes(linetype=grp, colour=grp))+
  scale_linetype_manual(values = lty_pal, guide = guide_legend(nrow = 5))+
  scale_colour_manual(values = biome_col)+
  scale_x_continuous(breaks = seq(2000,2023, by = 4))+
  labs(x="Year", y="CAR (%)")+
  theme(legend.title = element_blank(), 
        legend.position = "bottom"); car_get_plot


# CAR AT GET 2 SUMMARISED BY COUNTRY -------------------------------------------
car_avetrend <- ca_repres_get %>%
  group_by(pa_year) %>%
  summarise(mean_car = mean(ca_representivity),
            sd_car = sd(ca_representivity))%>% 
  mutate(year=as.numeric(as.character(pa_year)))


car_get_plot_rsa <- ggplot(data = car_avetrend, aes(x = year)) + 
  geom_line(aes(y = mean_car), linewidth = 1) + 
  geom_ribbon(aes(y = sd_car, ymin = mean_car - sd_car, 
                  ymax = mean_car + sd_car), alpha = .2) +
  scale_x_continuous(breaks = seq(2000,2023, by = 4))+
  coord_cartesian(ylim = c(0, NA))+
  labs(x="Year", y="CAR (%, mean \u00b1 SD)")

car_get_plot_rsa 

# CAR Average trend by GET 1 Realm --------------------------------------------

car_avetrend_grp <- ca_repres_get %>%
  right_join(getrealm, by=join_by("getbiome_code")) %>% 
  group_by(get_realm, pa_year) %>%
  summarise(mean_car = mean(ca_representivity),
            sd_car = sd(ca_representivity)) %>% 
  mutate(year=as.numeric(as.character(pa_year)))



car_get_plot_realm <- ggplot(data = car_avetrend_grp, aes(x = year, group=get_realm)) + 
  geom_line(aes(y = mean_car, color=get_realm), linewidth = 1) + 
  scale_color_manual(values=c("darkblue", "forestgreen", "gold"))+
  geom_ribbon(aes(y = sd_car, ymin = mean_car - sd_car, 
                  ymax = mean_car + sd_car, fill=get_realm), alpha = .1) +
  scale_fill_manual(values=c("darkblue", "forestgreen", "gold"))+
  coord_cartesian(ylim = c(0, NA))+
  scale_x_continuous(breaks = seq(2000,2023, by = 4))+
  labs(x="Year", y="CAR (%, mean \u00b1 SD)", col="", fill="") +
  theme(legend.position="none")
#   theme(legend.position = c(0.1,0.9))

car_get_plot_realm


XX <-ggarrange(car_get_plot_rsa,  ave_EPLI_graph,
               nrow = 1,ncol=2, common.legend = F, labels = c(letters[1:2]),
               widths = c(0.97, 1))
YY <-ggarrange(car_get_plot_realm, ave_EPLI_graph_GET1,
               nrow = 1,ncol=2, common.legend = F, labels = c(letters[3:4]),
               widths = c(0.97, 1))
ZZ <- ggarrange(car_get_plot, EPLI_get,
                nrow = 1,ncol=2, common.legend = T, labels = c(letters[5:6]), 
                legend="bottom", widths = c(0.97, 1))

ggarrange(XX,YY,ZZ, nrow = 3,ncol=1, heights =c(0.8,0.8,1.2))

#save as pdf 11 x 10 portrait
