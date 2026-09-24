library(ggpubr)
library(here)
library(ggpattern)
library(tidyverse)

# GET STARTED ------------------------------------------------------------------
source(here("code/B1_realm_get-started_plot-themes-palettes-functions.R"))


# EPL: BY TYPES & EXTENT -------------------------------------------------------
source(here("code/B2_realm_figure_epl-data-and-graphs.R"))


# EPLI: BY REALM ---------------------------------------------------------------
source(here("code/B3_realm_epli.R"))


# EPL: BY GET -----------------------------------------------------------------
source(here("code/B4_iucn_get_epl-data-and-graphs.R"))


# PLOT RESULTS -----------------------------------------------------------------
## Figure 4b,c,d (without EPL legend)
source(here("code/B1_realm_get-started_plot-themes-palettes-functions.R"))

ggarrange(ggarrange(epl_t, epl_e, ncol = 2, labels = c("b","c"), legend = "none"), 
          EPLI, nrow=2, labels=c("b","d"), heights = c(1,1.3))

## Figure 4b,c,d (with EPL legend)
#ggarrange(ggarrange(epl_t, epl_e, ncol = 2, labels = c("b","c"), common.legend = T, legend = "bottom"), EPL.C, nrow=2, labels=c("b","d"), heights=c(1.1,1))

#export pdf: 9.21 x 6.5

## Appendix S5
epl_tg

#export pdf: 10 x 9

### END SCRIPT ###