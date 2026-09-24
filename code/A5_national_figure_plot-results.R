##Set plot parameters
theme_set(theme_bw()+
            theme(axis.line = element_line(color='black'),
                  plot.background = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.grid.major = element_blank(),
                  axis.title.x  = element_blank(),
                  axis.text.y = element_text(size = 10),
                  axis.text.x = element_text(size = 10),
                  legend.text = element_text(size = 10),
                  legend.title=element_blank(),
                  legend.background = element_rect(fill='transparent'),
                  legend.key = element_rect(fill = "transparent"),
                  legend.justification=c(0,1), 
                  legend.position=c(0,1.04)))

# COMPILE DATA INTO SINGLE DATAFRAME -------------------------------------------
repres_data <- repres_ri %>%
  left_join(select(carepres_cari, !(total_area:pa_coverage)), by = "pa_year")

r_indicators <- repres_data %>%
  select(pa_year, pa_coverage, representivity, ca_representivity) %>%
  mutate(pa_year = as.numeric(as.character(pa_year))) %>%
  pivot_longer(!pa_year, names_to = "indicator", values_to = "proportion") %>%
  mutate(indicator = factor(indicator, levels = c("pa_coverage", 
                                                  "representivity",
                                                  "ca_representivity"),
                            ordered=T))

r_indices <- repres_data %>%
  select(pa_year, repres_index, cari) %>%
  pivot_longer(!pa_year, names_to = "index", values_to = "value") %>%
  mutate(pa_year = as.numeric(as.character(pa_year)),
         index = factor(index, levels=c("repres_index", "cari"))) %>%
  arrange(desc(index), pa_year)


# Plot -------------------------------------------------------------------------
r_indicators_graph <- ggplot(r_indicators)+ 
  geom_line(aes(x = pa_year, y = proportion, colour = indicator), linewidth=1.1) +
  scale_colour_manual(labels = c("Protected area coverage", 
                                 "Representativeness", 
                                 "Condition-adjusted representativeness"), 
   #                   values = c("#2c7fb8", "#7fcdbb", "#edf8b1")) +
   values = c("#a1dab4", "#41b6c4", "#225ea8")) +
  ylab("Proportion of SA Territory (%)") +
  scale_y_continuous(limits=c(0,14), breaks = seq(0,14, by = 2)) +
  scale_x_continuous(breaks = seq(2000,2023, by = 4))+
  theme(legend.position = c(0.01, 0.99))

r_indices_graph <- ggplot(r_indices)+ 
  geom_line(aes(x = pa_year, y = value, colour = index), linewidth=1.1) +
  scale_colour_manual(labels = c("Representativeness index", 
                                 "Condition-adjusted representativeness index"), 
                      values = c("#41b6c4", "#225ea8"))+
  ylab("Index")+
  ylim(0.5,1)+
  scale_x_continuous(breaks = seq(2000,2023, by = 4))+
  theme(legend.position = c(0.01, 0.99))

ggarrange(r_indicators_graph, r_indices_graph, ncol = 2, labels = c("b", "c"), common.legend = F)
