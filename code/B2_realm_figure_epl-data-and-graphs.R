library(ggpubr)
library(tidyverse)

# READ THE FUNCTIONS AND PALETTES ----------------------------------------------
#source("Code/B1_realm_get-started_plot-themes-palettes-functions.R")

# COMPILE THE DATA -------------------------------------------------------------
cat <- c("PEI",
        "Marine", 
        "Estuaries",
        "Wetlands", 
        "Rivers", 
        "Terrestrial")
epl <- c("Well Protected", 
        "Moderately Protected", 
        "Poorly Protected", 
        "Not Protected")  
n_types <- c(15,  14,   1,   4,  #P WP-MP-PP-NP
             47,  62,  22,  19,  #M 
              4,   8,   7,   3,  #E
              8,   4,  41,  82,  #W
             29,  33,  66,  94,  #R
            118,  59, 166, 115)  #T
n_extent <- c(    1.03,       95.26,         0.6,        3.11,  #P WP-MP-PP-NP
              52457.19,    78081.60,   386763.24,   558413.15,  #M 
                 23.02,      497.61,     1273.83,      212.90,  #E
              42088.10,     9009.30,   743040.80,  1842531.60,  #W
           16229203.48, 24113280.99, 98130096.26, 70968488.69,  #R
              90092.23,   136621.59,   415500.66,   317303.83)  #T
n_cat<-length(cat)

epl_types <- tibble(cat = factor(rep(cat, each = 4), levels=cat),
                  epl = factor(rep(epl, n_cat), levels=rev(epl)),  
                  n =  n_types)

epl_extent <- tibble(cat = factor(rep(cat, each = 4), levels=cat),
                     epl = factor(rep(epl, n_cat), levels=rev(epl)),  
                     n =  n_extent)

# PLOT RESULTS -----------------------------------------------------------------
epl_t <- epl_graph(epl_data=epl_types, metric="Types"); epl_t

epl_e <- epl_graph(epl_data=epl_extent, metric="Extent"); epl_e

ggarrange(epl_t, epl_e, ncol = 2, labels = c("b","c"), common.legend = T, legend = "bottom")

#export pdf: 7.97 x 4.23