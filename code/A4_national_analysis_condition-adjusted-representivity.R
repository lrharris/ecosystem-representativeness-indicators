library(sf)
library(rmapshaper)
#library(plyr)
library(here)
library(terra)
library(tidyverse)

# source(here("code","A1_national_get-started_load-inputs.R"))
# source(here("code", "A2_national_analysis_protected-area-extent.R"))
# source(here("code", "A3_national_analysis_representivity.R"))

## Load in condition data per realm --------------------------------------------
#for terrestrial, read in the raster and project it. Then make the field of interest (condition) the index field, and change the "Natural" areas to NA so we have raster cells only of poor condition
# t_cond <- rast(here("data", cond_gdb)) %>%
#   terra::project(crs(pa))
# activeCat(t_cond) <- tc_field
# levels(t_cond)[[1]]$LC14L1 <- revalue(cats(t_cond)[[1]]$LC14L1, c(tc_nat = NA, "Not natural"=1))
# t_cond1 <- st_as_sf(as.polygons(t_cond))

t_cond <- st_read(dsn=here("data", t_condition)) %>%
  st_transform(., st_crs(pa)) %>% 
  select(tc_field) %>% 
  rename(condition = tc_field)%>%
  filter(condition %in% tc_poor)

w_cond <- st_read(dsn=here("data", cond_gdb),layer=w_condition) %>%
  st_transform(., st_crs(pa)) %>% 
  select(wc_field) %>% 
  rename(condition = wc_field)%>%
  filter(condition %in% wc_poor)%>% 
  filter(st_is(. , c("MULTIPOLYGON")))

r_cond <- st_read(dsn=here("data", r_condition)) %>%
  st_transform(., st_crs(pa)) %>% 
  select(rc_field) %>% 
  rename(condition = rc_field)%>%
  filter(condition %in% rc_poor)

e_cond <- st_read(dsn=here("data", econd_gdb), layer=e_condition) %>%
  st_transform(., st_crs(pa))%>% 
  select(ec_field) %>% 
  rename(condition = ec_field)%>%
  filter(condition %in% e_poor)%>% 
  filter(st_is(. , c("MULTIPOLYGON")))

m_cond <- st_read(dsn=here("data", cond_gdb),layer=m_condition) %>%
  st_transform(., st_crs(pa)) %>% 
  select(mc_field) %>% 
  rename(condition = mc_field)%>%
  filter(condition %in% mc_poor)

#pei not calculated because there is no map of ecological condition for PEI yet. The analyses will assume all of PEI is in good to moderately modified ecological condition.

## Condition adjustment: erase portions of PAs that are not natural ------------
# Make a copy of the PA layer - one per realm, with each realm's poor condition
# habitat erased from the shp. 

cond_maps <- list(m_cond, m_cond, e_cond, r_cond, w_cond, t_cond)
out_name <- c("marine", "pelagic", "estuary", "river", "wetland", "terrestrial")

pa_cond <- pa %>%
  mutate(realm="pei")

for (i in 1:length(cond_maps)){
  pa_cond_temp <- pa %>%
    ms_erase(cond_maps[[i]]) %>%
    st_make_valid(pa_cond_temp) %>%
    mutate(realm=rep(out_name[i], times = nrow(.)))
  pa_cond<-rbind(pa_cond, pa_cond_temp)
}

rm(cond_maps)

## Calculate condition-adjusted statistics -------------------------------------
### Intersect ecosystem types with PAs and add the area of the intersection ----

realm_name <- unique(et_merge$realm)
intersection_c <- tibble()

for (i in 1:length(realm_name)){
  intersection_c_temp <- 
    tibble(st_intersection(et_merge[et_merge$realm==realm_name[i],],
                           pa_cond[pa_cond$realm==realm_name[i],]) %>%
             filter(st_is(. , c("POLYGON", "MULTIPOLYGON"))) %>%
             mutate(intersect_c_area_sqkm = st_area(.) %>%
                      units::set_units(km^2))) %>%
    select(!(geometry))
  intersection_c <- rbind(intersection_c, intersection_c_temp)
}

### Summarise PA area per ecosystem type per year ------------------------------
pa_et_yr_c <- intersection_c %>%
  group_by(realm, eco_type, pa_year, .drop=F) %>%
  summarize(intersect_c_area_yr =  sum(intersect_c_area_sqkm) %>% 
              units::set_units(km^2)) %>%
  mutate(cum_intersect_c_area_yr = cumsum(intersect_c_area_yr))%>%
  left_join(select(et_data, !(realm)), by="eco_type") %>%
  mutate(cum_intersect_c_area_yr_t = pmin(cum_intersect_c_area_yr, 
                                          target_et_area))

### Calculate Condition-Adjusted Representivity --------------------------------
# Summarize the ecosystem-level data by year to get the total area that
# comprises condition-adjusted, representative habitat. Then add the total
# protected area summed across the overlapping ecosystem types (from repres),
#  and add protected area coverage from pa_per_year. Calculate the conversion
# factor - factor by which the protected area coverage summed across all
# overlapping ecosystem types - in order to scale the amount of condition
# -adjusted, representative habitat to the protected area coverage per year.

ca_repres<-pa_et_yr_c %>% 
  group_by(pa_year) %>%
  summarize(cum_rep_c_area = sum(cum_intersect_c_area_yr_t)) %>%
  left_join(repres[,c(1,4)], by = join_by(pa_year)) %>% 
  left_join(pa_per_year, by = join_by(pa_year)) %>% 
  mutate(conversionfactor = as.numeric(cum_pa_area/cum_rep_add_area),
         cum_rep_c_area_adjusted = cum_rep_c_area*conversionfactor,
         ca_representivity=as.numeric(cum_rep_c_area_adjusted/studyarea*100))


### Calculate Condition-Adjusted Representivity Index (CARI) -------------------
carepres_cari <- ca_repres %>%
  mutate(cari = ca_representivity/pa_coverage)

#endscript ---------------------------------------------------------------------