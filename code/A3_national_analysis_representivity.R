library(sf)
library(tidyr)
library(here)
library(tidyverse)

## Get started -----------------------------------------------------------------
# source(here("code","A1_national_get-started_load-inputs.R"))
# source(here("code","A2_national_analysis_protected-area-extent.R"))

## Read in Ecosystem Types, simplify attributes, and add area ------------------
et<-st_read(dsn=here("data", et_gdb),layer=et_shp) %>%
  st_transform(., st_crs(pa)) %>%
  select(t_realm, t_et, e_realm, e_et, 
         mb_realm, mb_et, mp_realm, mp_et) %>%
  rename(t_realm=t_realm, t_et=t_et, e_realm=e_realm, e_et=e_et, 
         mb_realm=mb_realm, mb_et=mb_et, mp_realm=mp_realm, mp_et=mp_et) %>%
  mutate(et_area_sqkm = st_area(.) %>% 
           units::set_units(km^2))

### Make terrestrial map
t_et_map<-et %>%
  filter(t_realm == "Terrestrial", 
         !t_et %in% c("Non-terrestrial (Aquatic)", 
                      "Non-terrestrial (Estuarine Functional Zone)",
                      "Non-terrestrial (Microestuary)",
                      "")) %>%
  select(t_realm, t_et, et_area_sqkm) %>%
  rename(realm = t_realm, eco_type = t_et)

### Make marine benthic map
mb_et_map<-et %>%
  filter(mb_realm == "Marine",
         !mb_et %in% c(" ")) %>%
  select(mb_realm, mb_et, et_area_sqkm) %>%
  rename(realm = mb_realm, eco_type = mb_et)

### Make marine pelagic map
mp_et_map<-et %>%
  filter(mp_realm == "Pelagic") %>%
  select(mp_realm, mp_et, et_area_sqkm) %>%
  rename(realm = mp_realm, eco_type = mp_et)

### Make estuarine map
e_et_map<-et %>%
  filter(e_realm == "Estuary") %>%
  select(e_realm, e_et, et_area_sqkm) %>%
  rename(realm = e_realm, eco_type = e_et)

### Make wetland map
w_et_map<-st_read(dsn=here("data", wetl_gdb),layer=wetl_shp) %>%
  st_transform(., st_crs(pa)) %>% 
  mutate(w_realm=rep("Wetland", times=nrow(.))) %>% 
  select(w_realm, w_et) %>%
  rename(realm = w_realm, eco_type = w_et) %>%
  mutate(et_area_sqkm = st_area(.) %>% 
           units::set_units(km^2)) %>% 
  st_zm(.) %>% 
  filter(st_is(. , c("MULTIPOLYGON")),
         !(eco_type=="(River)" | 
             eco_type=="(Estuary)" | 
             eco_type=="(Foreign) (Depression)" |
             eco_type=="NA")) %>%
  st_make_valid(w_et_map)

### Make rivers map
r_et_map<-st_read(here("data"), layer=riv_shp)%>%
  st_transform(., st_crs(pa)) %>% 
  mutate(r_realm=rep("River", times=nrow(.))) %>% 
  select(r_realm, r_et) %>%
  rename(realm = r_realm, eco_type = r_et, Shape = geometry) %>%
  mutate(et_area_sqkm = st_area(.) %>% 
           units::set_units(km^2)) %>% 
  st_zm(.) %>% 
  filter(st_is(. , c("MULTIPOLYGON"))) %>% 
  st_make_valid(r_et_map)
  
### Make PEI map
pei_et_map <- st_read(here("data"), layer=pei_shp) %>%
  st_transform(., st_crs(pa)) %>% 
  mutate(pei_realm=rep("PEI", times=nrow(.))) %>% 
  select(pei_realm, pei_et) %>%
  rename(realm = pei_realm, eco_type = pei_et, Shape = geometry) %>%
  mutate(et_area_sqkm = st_area(.) %>% 
           units::set_units(km^2))

### Merge ecosystem type maps across realms
et_merge<-rbind(t_et_map, w_et_map, r_et_map, e_et_map, 
                mb_et_map, mp_et_map, pei_et_map) %>%
  mutate(realm = tolower(realm))%>%
  rename(geometry=Shape) %>% 
  filter(st_is(. , c("MULTIPOLYGON", "POLYGON"))) 

## Calculate ecosystem type area and calculate the target area for protection ----
et_data<- tibble(et_merge) %>%
  select(!(geometry)) %>%
  group_by(realm, eco_type) %>%
  summarize(total_et_area =  sum(et_area_sqkm) %>% 
              units::set_units(km^2)) %>%
  mutate(target = target, target_et_area = total_et_area*target)%>%
  ungroup()

## Intersect ecosystem types with PAs and add the area of the intersection -----
intersection <- tibble(st_intersection(et_merge, pa) %>% 
  filter(st_is(. , c("POLYGON", "MULTIPOLYGON"))) %>%
  mutate(intersect_area_sqkm = st_area(.) %>% 
           units::set_units(km^2))) %>%
  select(!(geometry)) 

## Summarise PA area per ecosystem type per year, add targets and target amounts, then calculate protected et area only up to target -----------------------------
pa_et_yr <- intersection %>%
  group_by(realm, eco_type, pa_year, .drop=F) %>%
  summarize(intersect_area_yr =  sum(intersect_area_sqkm) %>% 
              units::set_units(km^2))%>%
  mutate(cum_intersect_area_yr = cumsum(intersect_area_yr))%>%
  left_join(select(et_data, !(realm)), by="eco_type")%>%
  mutate(cum_intersect_area_yr_t = pmin(cum_intersect_area_yr, target_et_area))

##Calculate Representivity -----------------------------------------------------
repres<-pa_et_yr %>% 
  group_by(pa_year) %>%
  summarize(cum_rep_area = sum(cum_intersect_area_yr_t),
            cum_additional_area = sum(cum_intersect_area_yr)-cum_rep_area,
            cum_rep_add_area = sum(cum_intersect_area_yr)) %>% 
  left_join(pa_per_year, by = join_by(pa_year)) %>% 
  mutate(conversionfactor = as.numeric(cum_pa_area/cum_rep_add_area),
         cum_rep_area_adjusted = cum_rep_area*conversionfactor,
         representivity=as.numeric(cum_rep_area_adjusted/studyarea*100))

## Calculate Representivity Index ----------------------------------------------
repres_ri <- repres %>%
  mutate(repres_index = representivity/pa_coverage)
