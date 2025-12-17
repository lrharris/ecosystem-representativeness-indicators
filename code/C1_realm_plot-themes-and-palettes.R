theme_set(theme_bw()+
            theme(axis.line = element_line(color='black'),
                  plot.background = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.grid.major = element_blank(),
                  axis.title.x = element_text(size = 12),
                  axis.text.y = element_text(size = 12),
                  axis.text.x = element_text(size = 10),
                  legend.background = element_rect(fill='transparent'),
                  legend.text=element_text(size=10)))

# EPL.condition<-c("#2c7fb8", "#7fcdbb", "#edf8b1")
EPL.condition<-c("#a1dab4", "#41b6c4", "#225ea8")
STRIPES=c(rep("transparent",7), rep("transparent",7), rep("#41b6c4",7))
