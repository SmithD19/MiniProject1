# convert NCBI ID to gbif ID for easy searching
library(tidyverse)
library(taxize)

ncbi_spp <- read_csv("data/resolved-ncbi-species.csv")

mos_names <- ncbi_spp %>% pull(scientificname)



# convert to gbif key - two ways:

# 1
# gbif_spp <- get_gbifid_(mos_names)
# gbif_spp %>% map(pull, specieskey) %>% bind_rows()

# 2 - this is easier
keys <-  mos_names %>% map_dfr(name_suggest) %>% drop_na()

# search gbif for the species

library(rgbif)

gbif_naive_search <- occ_search(taxonKey = keys$key, continent = "europe")

library(raster)

rgbif::map_fetch(taxonKey = keys$key[2]) %>% plot()
