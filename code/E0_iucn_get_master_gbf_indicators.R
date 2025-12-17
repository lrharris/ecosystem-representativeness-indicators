library(here)
library(ggpubr)
library(tidyverse)


# GET STARTED ------------------------------------------------------------------
## Set up the plot function
source(here("code","E1_iucn_get_set-plot-function.R"))

# CALCULATE INDICATORS ---------------------------------------------------------
## 1. EPLI by IUCN GET Levels
source(here("code", "E2_iucn_get_epli.R"))

## 2. Condition-Adjusted Representativeness by IUCN GET Levels
source(here("code", "E3_iucn_get_car.R"))

# PLOT RESULTS -----------------------------------------------------------------
## Figure 7
ggarrange(XX,YY,ZZ, nrow = 3,ncol=1, heights =c(0.8,0.8,1.2))
#save as pdf 11 x 10 portrait

### END SCRIPT ###