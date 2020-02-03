# Narrow down what species we're looking at in the paleoartic region
library(tidyverse)


# List of species given by Francis ----------------------------------------

# occ <-  read.csv("data/occurance.csv")

# Taxize / GBIF -----------------------------------------------------------

# These are the species that are recognised in the NCBI database
# ncbi_spp <- 
#   occ$species %>% # 104 without removal of extra text
#   str_remove(" s.l.") %>% # 113 With removal
#   str_remove(" s.s.") %>% # So we will remove the extra text
#   get_uid_() %>%
#   bind_rows()

# above code has now been written to file:
ncbi_spp <- read_csv("data/resolved-ncbi-species.csv")

# Search using rscopus to see what traits we return - how many hit --------

library(rscopus)

set_api_key("0358c060b53f10b73724542975cbc013")

# function to return hits
get_hits <-
  function(x) {
    y = scopus_search(x)
    y = y$total_results
    return(y)
  }

# load in the querys
source("scripts/search-terms.R")

# hits <- map_depth(querys, 2, get_hits)
hits <- map(querys, ~ map_dbl(., get_hits))

# give the vectors names
names(hits) <- names(querys)

# convert to dataframe
hits_mat <- bind_rows(hits) %>% as.matrix()

# give matrix rownames the species name
rownames(hits_mat) <- ncbi_spp$scientificname



# to a tidy tibble
hits_tib <- hits_mat %>% 
  # construct tibble
  as_tibble() %>% 
  mutate("scientificname" = ncbi_spp$scientificname) %>% 
  # tidy data
  pivot_longer(-scientificname, names_to = "trait", values_to = "hits") %>% 
  # add ncbi data
  inner_join(ncbi_spp)

# write .csv
# write_csv(hits_tib, "data/scopus-trait-hits.csv")


# Read in the previous chunk of code from a .csv --------------------------

hits_tib <- read_csv("data/scopus-trait-hits.csv")

# heatmap in ggplot2 by spp
hits_tib %>% mutate(hits_sqrt = sqrt(hits)) %>% 
  ggplot(aes(x = trait, y = species, fill = hits_sqrt)) +
  geom_tile() +
  scale_fill_viridis_c()

# heatmap by genus
hits_tib %>% group_by(trait, genus) %>% 
  summarise(
    hits = sqrt(sum(hits))
    ) %>%
  ggplot(aes(x = trait, y = genus, fill = hits)) +
  geom_raster() +
  coord_fixed() +
  scale_fill_viridis_c() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(fill = "Sqrt Hits") +
  xlab("Searched Trait") +
  ylab("Mosquito Genus")
  
  
hits_tib %>% #group_by(trait, species) %>% 
  mutate(hits = scaler(hits)) %>% 
  ggplot(aes(x = trait, y = genus, fill = hits)) +
  geom_raster() +
  coord_fixed() +
  scale_fill_viridis_c()


scaler <- function(x){(x-min(x))/(max(x)-min(x))}


