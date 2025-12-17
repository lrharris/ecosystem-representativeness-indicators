#FUNCTION TO MAKE THE EPLI_GET GRAPH ------------------------------------------------
epli_g_graph<-function(epli_g_data){
  ggplot(epli_g_data, aes(x=year, y=epli, group=grp))+
    geom_line(linewidth=1.1, aes(linetype=grp, colour=grp))+
    scale_linetype_manual(values = lty_pal)+
    scale_colour_manual(values = biome_col)+
    scale_y_continuous(limits=c(0,1))+
    scale_x_continuous(breaks = seq(2000,2023, by = 4))+
    labs(x="Year", y="EPLI")+
    theme(legend.title = element_blank(),
          legend.position=c(0.9,0.17),
          axis.text.y = element_text(size = 10))+
    guides(fill = guide_legend(ncol=1))
}