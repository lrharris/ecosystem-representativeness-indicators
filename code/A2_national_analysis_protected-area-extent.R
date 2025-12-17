library(sf)
library(here)
library(tidyverse)

## Get started -----------------------------------------------------------------
source(here("code","A1_national_get-started_load-inputs.R"))

## Read in PA shapefile, remove z and m points, and standardize names ----------
pa <- st_read(here("data"), layer=pa_shp) %>%
    st_zm(.) %>%
    select(pa_name, pa_year) %>%
    rename(pa_name = pa_name, 
           pa_year = pa_year) %>%
    mutate(pa_name = factor(pa_name), 
           pa_year = factor(pa_year, levels = study_years, ordered=T))

## Calculate area of each Protected Area (km2), summarise PA area by year ------ 
pa <- pa %>%
    mutate(pa_area_sqkm = st_area(pa) %>% 
           units::set_units(km^2))

## Summarise PA area by year, calculate cumulative protection over time (area, proportion) --------------------------------------------------------------------
pa_per_year <- tibble(pa %>%
            group_by(pa_year) %>%
            summarize(total_area = sum(pa_area_sqkm))) %>%
            select(!(geometry))%>%
            mutate(cum_pa_area = cumsum(total_area)) %>%
            mutate(pa_coverage = as.numeric(cum_pa_area/studyarea*100))

## Plot results ----------------------------------------------------------------
pa_temporal_graph <- pa_per_year %>%
                  mutate(pa_year = as.numeric(as.character(pa_year))) %>%
                  ggplot(aes(pa_year, pa_coverage)) +
                  geom_line() +
                  labs(y = "Proportion of SA Territory (%)", x = "Year"); pa_temporal_graph

