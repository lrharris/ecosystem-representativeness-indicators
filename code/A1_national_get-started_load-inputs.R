library(tidyverse)

## Specify input data and values -----------------------------------------------
### Protected areas ------------------------------------------------------------
pa_shp = "All_PAs_2023Q1" #name of PA shapefile
pa_name="CUR_NME"         #field in the PA shapefile with the name of the PAs 
pa_year="YR2000_202"      #field in the PA shapefile with the year of the PAs 

### Ecosystem types ------------------------------------------------------------
#name of file gdb and shp of integrated ecosystem map
et_gdb = "IEM_5_8_4_31012024_NWslivers_1.gdb" 
et_shp = "IEM_5_8_4_31012024_NWslivers_1_RSA" 

# realm = "I_Rlm_Prim"     #field in the ecosystem type shp with name of the realm
# eco_type = "EcoType"     #field in the ecosystem type shp with name of eco types

#names of the fields for the realms and the fields with their respective ecosystem types. Script assumes tag in each realm's column is the realm name with a capital (e.g., rows that are terrestrial ecosystem types are marked in I_Map_Terr as "Terrestrial").
t_realm   = "I_Map_Terr"
t_et      = "T_Name"
e_realm   = "I_Map_Est"
e_et      = "E_EcosType"
mb_realm  = "I_Map_Mar"
mb_et     = "M_EcosType"
mp_realm  = "I_Map_Pel"
mp_et     = "M_P_Ecsy"  

#shapefile name and ecosystem type field for PEI, wetlands, and rivers (i.e., ecosystem types that are not in the integrated ecosystem map)
pei_shp   = "PEI_2018_cleaned_AEA"
pei_et    = "EcoType"

wetl_gdb = "National_Wetland_Map5.gdb"  
wetl_shp = "NWM5_20191003_final_AEA" #name of wetland shapefile
w_et = "Wetland_ecosystem_type"

riv_shp   = "NBA2018_Rivers_Final_Sep2019_1m"
r_et    = "RIVTYPE"
  
### Ecological condition -------------------------------------------------------
# ecol_condition="T2014_M2018_poor_AEA" #name of ecological condition shapefile

#name of the file geodatabase with ecological condition for terrestrial, marine, and wetlands, and names of the respective realm files, field with ecological condition, and what the "poor condition" habitat text is per realm
cond_gdb <- "Condition NBA2018.gdb"

w_condition <- "Wetlands"
wc_field <- "WETCON2"
wc_poor <- "D/E/F"

m_condition <- "Marine"
mc_field <- "Condition"
mc_poor <- c("Severely Modified  (Poor)", "Very Severely Modified  (Very Poor)")

#read in the same files and inputs for terrestrial and estuaries
t_condition <- "NBA2018_HabMod_v51_120m1.shp"
tc_field <- "LC14L1"
tc_poor <- "Not natural"

econd_gdb <- "NBA2018_Estuarine_ThreatStatus_ProtectionLevel_Condition.gdb"
e_condition <- "NBA2018_Estuarine_ThreatStatus_ProtectionLevel_Condition_2018"
ec_field <- "COND"
e_poor <- c("Heavily", "Severely/Critical")

#river condition is in the ecosystem type shapefile
r_condition <- "NBA2018_Rivers_Final_Sep2019_1m.shp"
rc_field <- "PES_2018"
rc_poor <- c("D", "E", "F")

#pei_condition not calculated because there is no map of ecological condition for PEI yet. The analyses will assume all of PEI is in good to moderately modified ecological condition.

### Other values ---------------------------------------------------------------
target = 0.3 #ecosystem type target for protection
studyarea=2766364.687969 #NBA 2018 boundaries incl PEI (from IEM5713_clean)
study_years = as.character(2000:2023)


## Theme for plots -------------------------------------------------------------
theme_set(theme_bw()+
            theme(axis.line = element_line(color='black'),
                  plot.background = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.grid.major = element_blank(),
                  axis.title.x = element_text(size = 12),
                  axis.text.x = element_text(size = 10),
                  legend.background = element_rect(fill='transparent'),
                  legend.key = element_blank(),
                  legend.text=element_text(size=10)))