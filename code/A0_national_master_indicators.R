library(here)
library(sf)
library(rmapshaper)
#library(reshape2)
library(ggpubr)
library(tidyverse)


# GET STARTED ------------------------------------------------------------------
## Load values. If there are any modifications, make them in script A1.
source(here("code","A1_national_get-started_load-inputs.R"))

# CALCULATE INDICATORS ---------------------------------------------------------
## 1. Protected Area Extent
source(here("code", "A2_national_analysis_protected-area-extent.R"))

## 2. Representativeness & Representativeness Index
source(here("code", "A3_national_analysis_representivity.R"))

## 3. Condition-Adjusted Representativeness & Condition-Adjusted Representativeness Index
source(here("code", "A4_national_analysis_condition-adjusted-representivity.R"))


# PLOT RESULTS ------------------------------------------------------------------
## Figure 3b,c
source(here("code", "A5_national_figure_plot-results.R"))

ggarrange(r_indicators_graph, r_indices_graph, ncol = 2, labels = c("b", "c"),
          common.legend = F)

#2 x 1 export pdf 9.79 x 4.23


### END SCRIPT ###