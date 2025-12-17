library(scales)

# SET PLOT THEME ---------------------------------------------------------------
theme_set(theme_bw()+
            theme(axis.line = element_line(color='black'),
                  plot.background = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.grid.major = element_blank(),
                  axis.title.x = element_text(size = 12),
                  axis.text.x = element_text(size = 10),
                  legend.background = element_rect(fill='transparent'),
                  legend.key = element_blank(),
                  legend.text=element_text(size=10)))

# LOAD COLOUR PALETTES ---------------------------------------------------------
## Actual realm colours:
# realm_col<-c("#617016", "#4097C2", "#9BC0DC", "#028A85", "#02268A", 
#              "#2F94C1", "#837196")

realm_col<-c("#a50026", "#f46d43", "#fdae61", "#fee090","#313695", "#4575b4", "#abd9e9")

epl_col=c("#A6A6A6", "#D5DDC5", "#84AB5C", "#4B6D02")

biome_col<-c("#005a32", "#238443", "#41ab5d", 
             "#78c679", "#addd8e", "#d9f0a3", 
             "#fec44f", "#fe9929", "#ec7014", "#cc4c02", "#8c2d04", 
             "#9ecae1", "#3182bd", "#08519c", "hotpink")

lty_pal <- c("solid", "1343", "22", "33", "44", "12", "11",
             "14", "21", "55", "36", "2141", "63", "4111")


# FUNCTION TO MAKE THE EPL GRAPHS ----------------------------------------------
epl_graph<-function(epl_data, metric){
  ggplot(epl_data, aes(x = cat, y = n))+
    geom_col(aes(fill = epl), width = 0.7, position="fill")+
    coord_flip()+
    scale_fill_manual(values = epl_col)+
    labs(x="", y=paste("Percent of Ecosystem", metric))+
    scale_y_continuous(labels = scales::percent)+
    theme(legend.position="bottom",
          legend.title = element_blank(),
          axis.text.y = element_text(size = 12))+
    guides(fill = guide_legend(reverse = TRUE))
}


#FUNCTION TO MAKE THE EPLI GRAPH ------------------------------------------------
epli_graph<-function(epli_data){
  ggplot(epli_data, aes(x=year, y=epli, group=grp))+
    geom_line(linewidth=1, aes(colour=grp))+ 
    scale_colour_manual(values = realm_col)+
    scale_y_continuous(limits=c(0,1))+
    scale_x_continuous(breaks = seq(2000,2023, by = 4))+
    labs(x="Year", y="EPLI")+
    theme(legend.title = element_blank(),
          legend.position=c(0.15,0.85),
          axis.text.y = element_text(size = 10))+
    guides(colour = guide_legend(ncol=2), 
           linetype = guide_legend(ncol=2))
}


