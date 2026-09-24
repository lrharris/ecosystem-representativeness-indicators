library(here)
library(tidyverse)

## Load themes and palettes ----------------------------------------------------
source(here("code/C1_realm_plot-themes-and-palettes.R"))


# PROTECTED EXTENT BY CONDITION (REALMS) ---------------------------------------
source(here("code/C2-realm-pa-coverage-representivity-car.R"))


# PROTECTED EXTENT BY CONDITION (GET) ------------------------------------------
source(here("code/C3_get_efg_pa_coverage_representivity_car.R"))


# PLOT RESULTS -----------------------------------------------------------------
## Figure 5
EPL.C

#export pdf: 10 x 3.7


## Appendix S6
EPL.CG

#Save as pdf 10 x 9

### END SCRIPT ###